package main

import (
	"context"
	"flag"
	"log"
	"time"

	"github.com/bazelbuild/bazel-toolchains/pkg/monitoring"
)

var (
	projectID = flag.String("project_id", "", "GCP Project ID")
)

func main() {
	flag.Parse()
	ctx := context.Background()
	m, err := monitoring.NewClient(ctx, *projectID)
	if err != nil {
		log.Fatalf("Unable to initialize monitoring client: %v", err)
	}
	time.Sleep(time.Second * 2)
	if err := m.ReportToolchainConfigsGeneration(ctx, "rbe-ubuntu1604", true); err != nil {
		log.Fatalf("Unable to report to Stackdriver monitoring: %v", err)
	}
	if err := m.ReportToolchainConfigsUpload(ctx, "rbe-ubuntu1604", true); err != nil {
		log.Fatalf("Unable to report to Stackdriver monitoring: %v", err)
	}
	if err := m.ReportToolchainConfigsTest(ctx, "rbe-ubuntu1604", true); err != nil {
		log.Fatalf("Unable to report to Stackdriver monitoring: %v", err)
	}
}
