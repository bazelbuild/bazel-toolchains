## Toolchain Containers

This folder contains artifacts for building a docker container which includes
all necessary language toolchains (C++, Java, Python, Go and libraries). This
container will be the recommended toolchain container for [Remote caching and
execution with
Bazel](https://github.com/bazelbuild/bazel/tree/master/src/main/java/com/google/devtools/build/lib/remote).

## Before you begin

1.  Download and install the [Google Cloud
    SDK](https://cloud.google.com/sdk/docs/), which includes the
    [gcloud](https://cloud.google.com/sdk/gcloud/) command-line tool.

1.  Create a [new Google Cloud Platform project from the Cloud
    Console](https://console.cloud.google.com/project) or use an existing one.

1.  Initialize the Cloud SDK.

        gcloud init

## Usage

You will need a valid project ID to build the toolchain-container.

You can build a toolchain-container with
[debian8](https://console.cloud.google.com/launcher/details/google/debian8)
as the base container by running:

    container/debian8-clang-fully-loaded/build.sh -p your-project-id -c debian8-clang-fully-loaded -t latest

Congratulations! Your docker container is now available in [Container
Registry](https://cloud.google.com/container-registry/)

    gcr.io/your-project-id/debian8-clang-fully-loaded:latest

You can pull the built container to local

    gcloud docker -- pull gcr.io/your-project-id/debian8-clang-fully-loaded:latest
