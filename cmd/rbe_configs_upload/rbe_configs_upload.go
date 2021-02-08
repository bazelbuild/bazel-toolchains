// Binary rbe_configs_upload uploads the artifacts generated by rbe_configs_gen to GCS. This tool
// is meant for internal use by the owners of this repository only.
// This tool will upload the given configs tarball & manifest to the following paths on GCS:
// - gs://rbe-bazel-toolchains/configs/latest
// - - rbe_default.tar (The configs tarball)
// - - manifest.json (The JSON manifest)
// - gs://rbe-bazel-toolchains/configs/bazel_<version>/latest
// - - rbe_default.tar (The configs tarball)
// - - manifest.json (The JSON manifest)
// This tool will upload the above files even if the config tarball hasn't changed. This can happen
// if there's been no new Bazel release or toolchain container release since the last time this tool
// was run. Thus, the above GCS artifacts are unstable in the sense that their contents can change
// if either a new Bazel or toolchain container is release. This is to avoid users depending on
// these GCS artifacts in production. Instead, users should copy the artifacts into a GCS bucket
// or other remote location under their control.
package main

import (
	"bytes"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"time"

	"cloud.google.com/go/storage"
	"github.com/bazelbuild/bazel-toolchains/pkg/rbeconfigsgen"
)

var (
	configsTarball  = flag.String("configs_tarball", "", "Path to the configs tarball generated by rbe_configs_gen to be uploaded to GCS.")
	configsManifest = flag.String("configs_manifest", "", "Path to the JSON manifest generated by rbe_configs_gen.")
)

// manifest is the metadata about the configs that'll be uploaded to GCS.
type manifest struct {
	// Wrap around the manifest produced by rbe_configs_gen.
	rbeconfigsgen.Manifest
	// UploadTime is the time this manifest was uploaded. For information only.
	UploadTime time.Time `json:"upload_time"`
}

// manifestFromFile loads the JSON manifest (in the format produced by rbe_configs_gen) from the
// given file and injects the current time in the returned manifest object.
func manifestFromFile(filePath string) (*manifest, error) {
	blob, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, fmt.Errorf("unable to read manifest JSON file %q: %w", filePath, err)
	}
	m := &manifest{}
	if err := json.Unmarshal(blob, m); err != nil {
		return nil, fmt.Errorf("error parsing contents of manifest file %q as JSON: %w", filePath, err)
	}
	// Ensure the mandatory fields used by this binary were specified.
	if len(m.BazelVersion) == 0 {
		return nil, fmt.Errorf("manifest %q did not specify bazel version", filePath)
	}
	m.UploadTime = time.Now()
	return m, nil
}

// storageClient represents the GCS client.
type storageClient struct {
	client *storage.Client
	// bucketName is the GCS bucket all artifacts will be uploaded to.
	bucketName string
}

func newStorage(ctx context.Context) (*storageClient, error) {
	c, err := storage.NewClient(ctx)
	if err != nil {
		return nil, err
	}
	return &storageClient{
		client:     c,
		bucketName: "rbe-bazel-toolchains",
	}, nil
}

// upload uploads the bytes represented by the given reader as the given GCS object name.
func (s *storageClient) upload(ctx context.Context, r io.Reader, objectName string) error {
	w := s.client.Bucket(s.bucketName).Object(objectName).NewWriter(ctx)
	if _, err := io.Copy(w, r); err != nil {
		return fmt.Errorf("error while uploading to GCS object %q: %w", objectName, err)
	}
	// The actual upload might happen after Close is called so we need to capture any errors.
	if err := w.Close(); err != nil {
		return fmt.Errorf("error finishing upload to GCS object %q: %w", objectName, err)
	}
	return nil
}

// uploadArtifacts uploads the given blob of bytes representing a JSON manifest and the configs
// tarball at the given path to the given GCS directory.
func (s *storageClient) uploadArtifacts(ctx context.Context, manifest []byte, tarballPath, remoteDir string) error {
	if err := s.upload(ctx, bytes.NewBuffer(manifest), fmt.Sprintf("%s/manifest.json", remoteDir)); err != nil {
		return fmt.Errorf("error uploading manifest to GCS: %w", err)
	}

	f, err := os.Open(tarballPath)
	if err != nil {
		return fmt.Errorf("unable to open configs tarball file %q: %w", tarballPath, err)
	}
	defer f.Close()
	if err := s.upload(ctx, f, fmt.Sprintf("%s/rbe_default.tar", remoteDir)); err != nil {
		return fmt.Errorf("error uploading configs tarball to GCS: %w", err)
	}
	return nil
}

func main() {
	flag.Parse()

	if len(*configsTarball) == 0 {
		log.Fatalf("--configs_tarball was not specified.")
	}
	if len(*configsManifest) == 0 {
		log.Fatalf("--configs_manifest was not specified.")
	}

	ctx := context.Background()
	sc, err := newStorage(ctx)
	if err != nil {
		log.Fatalf("Failed to initialize the GCS client: %v", err)
	}

	m, err := manifestFromFile(*configsManifest)
	if err != nil {
		log.Fatalf("Error reading config manifest: %v", err)
	}
	manifestBlob, err := json.MarshalIndent(m, "", " ")
	if err != nil {
		log.Fatalf("Error converting manifest into JSON: %v", err)
	}

	uploadDirs := []string{
		"configs/latest",
		fmt.Sprintf("configs/bazel_%s/latest", m.BazelVersion),
	}
	for _, u := range uploadDirs {
		if err := sc.uploadArtifacts(ctx, manifestBlob, *configsTarball, u); err != nil {
			log.Fatalf("Error uploading configs to GCS bucket %s, directory %s: %v", sc.bucketName, u, err)
		}
		log.Printf("Configs published to GCS bucket %s, directory %s.", sc.bucketName, u)
	}
	log.Printf("Configs published successfully.")
}
