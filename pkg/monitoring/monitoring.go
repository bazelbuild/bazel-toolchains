// Copyright 2021 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Package monitoring provides functionality to report metrics to Google Cloud Monitoring a.k.a.
// Stackdriver.
package monitoring

import (
	"context"
	"fmt"
	"time"

	monitoring "cloud.google.com/go/monitoring/apiv3"
	"github.com/golang/protobuf/ptypes/timestamp"
	gax "github.com/googleapis/gax-go/v2"
	"google.golang.org/genproto/googleapis/api/label"
	"google.golang.org/genproto/googleapis/api/metric"
	"google.golang.org/genproto/googleapis/api/monitoredres"
	monitoringpb "google.golang.org/genproto/googleapis/monitoring/v3"
)

const (
	// Metric types for metrics reported by this package to Cloud Monitoring. See docs for "type" in
	// https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors#resource:-metricdescriptor.

	// BEGIN Metrics for Toolchain Configs Generation
	//
	// All toolchain config generation metrics have the following characterics:
	// 1. Cumulative integer tracking the number of times a toolchain configs release step
	//    (generation, upload & test) runs to completion.
	// 2. Each metric includes the following labels:
	//    a. docker_image- A string representing the OS name of the toolchain docker image. e.g.,
	//                     "rbe-ubuntu1604".
	//    b. success- Bool set to true if the step succeeded.
	//
	// mtypeToolchainConfigsGenRuns tracks successful runs of rbe_configs_gen i.e., configs
	// generation.
	mtypeToolchainConfigsGenRuns = "custom.googleapis.com/rbe/bazel-toolchains/generation/runs"
	//
	// mtypeToolchainConfigsUploadRuns tracks successful runs of rbe_configs_upload i.e.,
	// configs publication/deployment.
	mtypeToolchainConfigsUploadRuns = "custom.googleapis.com/rbe/bazel-toolchains/upload/runs"
	//
	// mtypeToolchainConfigsTestRuns tracks successful runs of configs_e2e i.e.,
	// configs end to end test.
	mtypeToolchainConfigsTestRuns = "custom.googleapis.com/rbe/bazel-toolchains/test/runs"
	// END Metrics for Toolchain Configs Generation
)

// metricClient provides functionality used by this package to interact with the Cloud Monitoring
// Metrics API.
type metricClient interface {
	CreateMetricDescriptor(ctx context.Context, req *monitoringpb.CreateMetricDescriptorRequest, opts ...gax.CallOption) (*metric.MetricDescriptor, error)
	DeleteMetricDescriptor(ctx context.Context, req *monitoringpb.DeleteMetricDescriptorRequest, opts ...gax.CallOption) error
	CreateTimeSeries(ctx context.Context, req *monitoringpb.CreateTimeSeriesRequest, opts ...gax.CallOption) error
}

// Client is the handle to interact with Google Cloud Monitoring.
type Client struct {
	// mc is the internal handle to the Google Cloud Monitoring API client.
	mc metricClient
	// projectID is the GCP project ID where Stackdriver metrics will be reported to.
	projectID string
	resetTs   time.Time
}

// NewClient initializes a new monitoring client.
func NewClient(ctx context.Context, projectID string) (*Client, error) {
	if len(projectID) == 0 {
		return nil, fmt.Errorf("GCP project ID was not specified")
	}
	mc, err := monitoring.NewMetricClient(ctx)
	if err != nil {
		return nil, fmt.Errorf("unable to initialize the Google Cloud Monitoring Metrics Client: %w", err)
	}
	c := &Client{
		mc:        mc,
		projectID: projectID,
		resetTs:   time.Now(),
	}
	if err := c.createMetrics(ctx); err != nil {
		return nil, fmt.Errorf("error initializing Google Cloud Monitoring Metrics Descriptors: %w", err)
	}
	return c, nil
}

// createMetrics creates descriptors for metrics reported by this client.
func (c *Client) createMetrics(ctx context.Context) error {
	if err := c.createToolchainConfigsMetrics(ctx); err != nil {
		return fmt.Errorf("unable to initialize the toolchain config runs metric: %w", err)
	}
	return nil
}

// createToolchainConfigsMetrics creates smetrics descriptors for the toolchain configs generation.
func (c *Client) createToolchainConfigsMetrics(ctx context.Context) error {
	metrics := []struct {
		name        string
		metricType  string
		description string
	}{
		{
			name:        "RBE Toolchain Configs Generation",
			metricType:  mtypeToolchainConfigsGenRuns,
			description: "Count number of times RBE Bazel C++/Java toolchain config generation completed",
		},
		{
			name:        "RBE Toolchain Configs Upload",
			metricType:  mtypeToolchainConfigsUploadRuns,
			description: "Count number of times RBE Bazel C++/Java toolchain config upload completed",
		},
		{
			name:        "RBE Toolchain Configs E2E Test",
			metricType:  mtypeToolchainConfigsTestRuns,
			description: "Count number of times RBE Bazel C++/Java toolchain config e2e test completed",
		},
	}

	for _, m := range metrics {
		md := &metric.MetricDescriptor{
			Name: m.name,
			Type: m.metricType,
			Labels: []*label.LabelDescriptor{
				{
					Key:         "docker_image",
					ValueType:   label.LabelDescriptor_STRING,
					Description: "Name of the OS of the toolchain container image",
				},
				{
					Key:         "success",
					ValueType:   label.LabelDescriptor_BOOL,
					Description: "Indicates of configs generation, upload & testing was successful",
				},
			},
			MetricKind:  metric.MetricDescriptor_CUMULATIVE,
			ValueType:   metric.MetricDescriptor_INT64,
			Unit:        "1",
			Description: m.description,
			DisplayName: m.name,
		}
		req := &monitoringpb.CreateMetricDescriptorRequest{
			Name:             "projects/" + c.projectID,
			MetricDescriptor: md,
		}
		if _, err := c.mc.CreateMetricDescriptor(ctx, req); err != nil {
			return fmt.Errorf("unable to create Google Cloud Monitoring Metric for %s: %v", m.name, err)
		}
	}
	return nil
}

// reportCumulativeCount reports the given metric type which is expected to be of kind
// cumulative (https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors#metrickind)
// adding "1" to the cumulative count. Other arguments:
// imageName: The toolchain container image for which the metric is being reported.
// success: Indicates if the workflow was successful.
func (c *Client) reportCumulativeCount(ctx context.Context, metricType, imageName string, success bool) error {
	reset := &timestamp.Timestamp{
		Seconds: c.resetTs.Unix(),
	}
	// For cumulative metrics, end time should be > than reset time. Thus, sleep for 2 seconds if
	// we find less than 1s has passed since resetTs. Sleep 2s instead of 1s to avoid flakes
	// from floating point addition errors.
	// This logic doesn't handle when time jumps back during daylight savings but we don't care
	// because:
	// 1. May cause a spurious but self recovering alert once a year which is too infrequent to
	//    bother handling.
	// 2. We expect to run this tool during business hours and daylight savings usually doesn't
	//    happen during then.
	if time.Now().Sub(c.resetTs).Seconds() < 1 {
		time.Sleep(time.Second * 2)
	}
	now := &timestamp.Timestamp{
		Seconds: time.Now().Unix(),
	}
	req := &monitoringpb.CreateTimeSeriesRequest{
		Name: "projects/" + c.projectID,
		TimeSeries: []*monitoringpb.TimeSeries{{
			Metric: &metric.Metric{
				Type: metricType,
				Labels: map[string]string{
					"docker_image": imageName,
					"success":      fmt.Sprintf("%v", success),
				},
			},
			// Cloud Monitoring insists a "Resource" be defined if we want to create alerts based
			// on the metric. The values here are mostly placeholders to satisfy Cloud Monitoring.
			// See https://cloud.google.com/monitoring/api/resources#tag_generic_task
			Resource: &monitoredres.MonitoredResource{
				Type: "generic_task",
				Labels: map[string]string{
					"project_id": c.projectID,
					"job":        "monitoring",
					// Cloud monitoring errors out unless we provide a location recognized by GCP or
					// AWS.
					"location":  "us-central1",
					"namespace": "monitoring",
					"task_id":   "monitoring",
				},
			},
			Points: []*monitoringpb.Point{{
				Interval: &monitoringpb.TimeInterval{
					StartTime: reset,
					EndTime:   now,
				},
				Value: &monitoringpb.TypedValue{
					Value: &monitoringpb.TypedValue_Int64Value{
						Int64Value: int64(1),
					},
				},
			}},
		}},
	}
	if err := c.mc.CreateTimeSeries(ctx, req); err != nil {
		return fmt.Errorf("unable to report time series to Google Cloud Monitoring: %w", err)
	}
	return nil
}

// ReportToolchainConfigsGeneration reports the completion of toolchain configs generation to
// Stackdriver.
func (c *Client) ReportToolchainConfigsGeneration(ctx context.Context, imageName string, success bool) error {
	if err := c.reportCumulativeCount(ctx, mtypeToolchainConfigsGenRuns, imageName, success); err != nil {
		return fmt.Errorf("unable to report toolchain config generation: %w", err)
	}
	// If config generation failed, we expect to skip running config upload & tests. However,
	// this may trigger alerts related to "upload" & "test" because the rbe_config_upload &
	// config_e2e binaries won't be run. Thus, we explicitly report failures for them here.
	if !success {
		return c.ReportToolchainConfigsUpload(ctx, imageName, false)
	}
	return nil
}

// ReportToolchainConfigsUpload reports the completion of toolchain configs upload to
// Stackdriver.
func (c *Client) ReportToolchainConfigsUpload(ctx context.Context, imageName string, success bool) error {
	if err := c.reportCumulativeCount(ctx, mtypeToolchainConfigsUploadRuns, imageName, success); err != nil {
		return fmt.Errorf("unable to report toolchain config upload: %w", err)
	}
	// If config upload failed, we expect to skip running config tests. However, this may trigger
	// alerts related to "test" not running because the config_e2e binary won't be run.
	if !success {
		return c.ReportToolchainConfigsTest(ctx, imageName, false)
	}
	return nil
}

// ReportToolchainConfigsTest reports the completion of toolchain configs test to
// Stackdriver.
func (c *Client) ReportToolchainConfigsTest(ctx context.Context, imageName string, success bool) error {
	if err := c.reportCumulativeCount(ctx, mtypeToolchainConfigsTestRuns, imageName, success); err != nil {
		return fmt.Errorf("unable to report toolchain config test run: %w", err)
	}
	return nil
}

// DeleteMetrics deletes all metrics known to this client. Exists for convenience to help with
// cleanup when metrics are being renamed.
// Caveat: This only deletes the metric descriptors. Metric data already reported can't be deleted &
// are deleted according to Cloud Monitoring retention policies. Cloud monitoring will continue to
// charge for the data until it's deleted by the retention policy. However, deleting the metric
// descriptors renders the data inaccessible even though they still generate charges.
func (c *Client) DeleteMetrics(ctx context.Context) error {
	m := []string{
		mtypeToolchainConfigsGenRuns,
		mtypeToolchainConfigsTestRuns,
		mtypeToolchainConfigsUploadRuns,
	}
	for _, metric := range m {
		req := &monitoringpb.DeleteMetricDescriptorRequest{
			Name: fmt.Sprintf("projects/%s/metricDescriptors/%s", c.projectID, metric),
		}

		if err := c.mc.DeleteMetricDescriptor(ctx, req); err != nil {
			return fmt.Errorf("could not delete metric %s: %v", metric, err)
		}
	}
	return nil
}
