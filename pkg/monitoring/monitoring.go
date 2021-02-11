// Package monitoring provides functionality to report metrics to Google Cloud Monitoring a.k.a.
// Stackdriver.
package monitoring

import (
	"context"
	"fmt"

	monitoring "cloud.google.com/go/monitoring/apiv3"
	"google.golang.org/genproto/googleapis/api/label"
	"google.golang.org/genproto/googleapis/api/metric"
	monitoringpb "google.golang.org/genproto/googleapis/monitoring/v3"
)

const (
	// Metric types for metrics reported by this package to Cloud Monitoring. See docs for "type" in
	// https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors#resource:-metricdescriptor.

	// BEGIN Metrics for Toolchain Configs Generation
	//
	// All toolchain config generation metrics have the following characterics:
	// 1. Cummulative integer tracking the number of times a toolchain configs release step 
	//    (generation, upload & test) runs to completion. 
	// 2. Each metric includes the following labels:
	//    a. docker_image- A string representing the OS name of the toolchain docker image. e.g.,
	//                     "rbe-ubuntu1604".
	//    b. result- Bool set to true if the step succeeded.
	//
	// mtypeToolchainConfigsGenRuns tracks successful runs of rbe_configs_gen i.e., configs
	// generation.
	mtypeToolchainConfigsGenRuns = "custom.googleapis.com/toolchain_configs/generation/runs"
	//
	// mtypeToolchainConfigsUploadRuns tracks successful runs of rbe_configs_upload i.e., 
	// configs publication/deployment.
	mtypeToolchainConfigsUploadRuns = "custom.googleapis.com/toolchain_configs/upload/runs"
	//
	// mtypeToolchainConfigsTestRuns tracks successful runs of configs_e2e i.e., 
	// configs end to end test.
	mtypeToolchainConfigsTestRuns = "custom.googleapis.com/toolchain_configs/test/runs"
	// END Metrics for Toolchain Configs Generation
)

// Client is the handle to interact with Google Cloud Monitoring.
type Client struct {
	// mc is the internal handle to the Google Cloud Monitoring API client.
	mc *monitoring.MetricClient
	// projectID is the GCP project ID where Stackdriver metrics will be reported to.
	projectID string
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
	md := &metric.MetricDescriptor{
		Name: "RBE Toolchain Configs Generation",
		Type: mtypeToolchainConfigsRuns,
		Labels: []*label.LabelDescriptor{
			{
				Key:         "docker_image",
				ValueType:   label.LabelDescriptor_STRING,
				Description: "Name of the OS of the toolchain container image",
			},
			{
				Key:         "result",
				ValueType:   label.LabelDescriptor_BOOL,
				Description: "Indicates of configs generation, upload & testing was successful",
			},
		},
		MetricKind:  metric.MetricDescriptor_CUMULATIVE,
		ValueType:   metric.MetricDescriptor_INT64,
		Unit:        "1",
		Description: "Count number of times RBE Bazel C++/Java toolchain config generation completed using labels to track variants and success/failure.",
		DisplayName: "RBE Toolchain Configs Generation",
	}
	req := &monitoringpb.CreateMetricDescriptorRequest{
		Name:             "projects/" + c.projectID,
		MetricDescriptor: md,
	}
	if _, err := c.mc.CreateMetricDescriptor(ctx, req); err != nil {
		return fmt.Errorf("could not create custom metric: %v", err)
	}
	return nil
}

func (c *Client) ReportToolchainConfigs