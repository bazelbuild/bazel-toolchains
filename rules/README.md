# Usage

This directory contains a skylark rule to generate the toolchain configs. See README.md under
the root directory for the definition of toolchain configs.

For a given version of Bazel, the `docker_toolchain_autoconfig` rule will:
* build the execution container image,
* install Bazel,
* build the container, and
* extract the toolchain config.

Refer to the documentation in docker_config.bzl for more details of how to execute this rule
and how to extract the toolchain configs.

The BUILD file in this directory contains 3 sample `docker_toolchain_autoconfig` targets which
use Bazel 0.7.0 to generate toolchain configs for:
* Debian8 Clang environment,
* Ubuntu Trusty GCC environment, and
* Ubuntu Xenial GCC environment.

# Authentication

If you are generating toolchain configs for the first time, you will probably encounter permission
issues while `docker` is trying to talk to `gcr.io`.

If `gcloud` is installed, use `gcloud` as the Docker credential helper by following the instructions [here](https://cloud.google.com/sdk/gcloud/reference/auth/configure-docker). Otherwise, use `docker-credential-gcr` by following the instructions [here](https://github.com/GoogleCloudPlatform/docker-credential-gcr).
