## Toolchain Containers

This folder contains artifacts for building a docker container which includes
all necessary language toolchains (C++, Java, Python, Go and libraries). This
container is the recommended toolchain container for [Remote caching and
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

1.  Authenticate `docker` to talk to `gcr.io` by following the instructions [here](https://cloud.google.com/sdk/gcloud/reference/auth/configure-docker).

## Usage

### Build with [Google Cloud Container Builder](https://cloud.google.com/container-builder/)

**Note: currently, this process can currently only be executed by users who have
read access to asci-toolchains's GCR, but we publish it here to make the build
process for our containers publicly available. You can still build the
containers locally. See instructions in the next section.**

You will need a valid project ID to build the toolchain-container.

You can build a toolchain-container with
[ubuntu16-04](https://console.cloud.google.com/gcr/images/cloud-marketplace/GLOBAL/google/ubuntu16_04) as
the base container by running:

``` shell
python container/build.py -p my-project-id -d rbe-ubuntu16_04 -c test-rbe-ubuntu16_04 -t latest -b my-gcs-bucket -v 0.15.2
```

Congratulations! Your docker container is now available in [Container
Registry](https://cloud.google.com/container-registry/)

```shell
gcr.io/my-project-id/test-rbe-ubuntu16_04:latest
```

You can pull the built container to local

```shell
gcloud docker -- pull gcr.io/my-project-id/test-rbe-ubuntu16_04:latest
```

### Build locally

You can also build rbe-ubuntu16-04 container locally to for a quick
test. You would need
[Bazel](https://docs.bazel.build/versions/master/install.html) and
[Docker](https://docs.docker.com/engine/installation/) installed.

Run the following command:

```shell
python container/build.py -l -d rbe-ubuntu16_04
```

You docker container is now available locally and you can try it out by running:

```shell
docker run -it rbe-ubuntu16_04:latest /bin/bash
```
