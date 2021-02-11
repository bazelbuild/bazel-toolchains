package main

import (
	"context"
	"flag"
	"log"

	"github.com/bazelbuild/bazel-toolchains/pkg/monitoring"
)

var (
	projectID = flag.String("project_id", "", "GCP Project ID")
)

func main() {
	flag.Parse()
	ctx := context.Background()
	_, err := monitoring.NewClient(ctx, *projectID)
	if err != nil {
		log.Fatalf("Unable to initialize monitoring client: %v", err)
	}
}
