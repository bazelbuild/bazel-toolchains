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
package monitoring

import (
	"context"
	"testing"
	"time"

	gax "github.com/googleapis/gax-go/v2"
	"google.golang.org/genproto/googleapis/api/metric"
	monitoringpb "google.golang.org/genproto/googleapis/monitoring/v3"
)

type fakeMonitoringClient struct {
	createTimeSeriesRequests []*monitoringpb.CreateTimeSeriesRequest
}

func (f *fakeMonitoringClient) CreateMetricDescriptor(_ context.Context, req *monitoringpb.CreateMetricDescriptorRequest, _ ...gax.CallOption) (*metric.MetricDescriptor, error) {
	return req.MetricDescriptor, nil
}

func (f *fakeMonitoringClient) DeleteMetricDescriptor(_ context.Context, _ *monitoringpb.DeleteMetricDescriptorRequest, _ ...gax.CallOption) error {
	return nil
}

func (f *fakeMonitoringClient) CreateTimeSeries(_ context.Context, req *monitoringpb.CreateTimeSeriesRequest, _ ...gax.CallOption) error {
	f.createTimeSeriesRequests = append(f.createTimeSeriesRequests, req)
	return nil
}

func TestReportToolchainConfigResults(t *testing.T) {
	testCases := []struct {
		name          string
		reportGen     bool
		reportUpload  bool
		reportTest    bool
		reportSuccess bool

		wantCreateTimeSeries int
	}{
		{
			name:                 "GenerationSuccess",
			reportGen:            true,
			reportSuccess:        true,
			wantCreateTimeSeries: 1,
		},
		{
			// If generation failed, we expect failures to be reported for upload & test as well.
			// Otherwise, we'll get upload & test jobs aren't running alerts.
			// will trigger.
			name:                 "GenerationFailedChainsUploadTestFailures",
			reportGen:            true,
			reportSuccess:        false,
			wantCreateTimeSeries: 3,
		},
		{
			name:                 "UploadSuccess",
			reportUpload:         true,
			reportSuccess:        true,
			wantCreateTimeSeries: 1,
		},
		{
			// If upload failed, we expect failures to be reported for test as well. Otherwise, our
			// internal we'll get test jobs aren't running alerts
			name:                 "UploadFailedChainsTestFailure",
			reportUpload:         true,
			reportSuccess:        false,
			wantCreateTimeSeries: 2,
		},
		{
			name:                 "TestSuccess",
			reportTest:           true,
			reportSuccess:        true,
			wantCreateTimeSeries: 1,
		},
		{
			name:                 "TestFailed",
			reportTest:           true,
			reportSuccess:        false,
			wantCreateTimeSeries: 1,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			tc := tc
			ctx := context.Background()
			fc := &fakeMonitoringClient{}
			mc := &Client{
				mc:        fc,
				projectID: "fake-project",
				resetTs:   time.Unix(0, 0),
			}
			if tc.reportGen {
				if err := mc.ReportToolchainConfigsGeneration(ctx, "fake", tc.reportSuccess); err != nil {
					t.Errorf("ReportToolchainConfigsGeneration(ctx, fake, %v) failed, got error %v, want nil", tc.reportSuccess, err)
				}
			}
			if tc.reportUpload {
				if err := mc.ReportToolchainConfigsUpload(ctx, "fake", tc.reportSuccess); err != nil {
					t.Errorf("ReportToolchainConfigsUpload(ctx, fake, %v) failed, got error %v, want nil", tc.reportSuccess, err)
				}
			}
			if tc.reportTest {
				if err := mc.ReportToolchainConfigsTest(ctx, "fake", tc.reportSuccess); err != nil {
					t.Errorf("ReportToolchainConfigsTest(ctx, fake, %v) failed, got error %v, want nil", tc.reportSuccess, err)
				}
			}
			if len(fc.createTimeSeriesRequests) != tc.wantCreateTimeSeries {
				t.Errorf("Unexpected number of time series requests, got %d, want %d.", len(fc.createTimeSeriesRequests), tc.wantCreateTimeSeries)
			}
		})
	}
}
