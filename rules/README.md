# Usage

This directory contains Starlark rules to generate toolchain configs that can be used
with remote execution. See README.md under the root directory for the definition of toolchain configs.

User facing rules in this repo are:
* `rbe_autoconfig` rule (see rbe_repo.bzl) is a repo rule that attempts to find toolchain configs that will work for your environment. If no toolchain configs are found, it pulls a container and generates them on demand. This rule also (optionally) can create the toolchain configs within your source tree.
* `docker_toolchain_autoconfig` rule (see docker_config.bzl) is a Starlark rule that builds a container and uses that to produce toolchain configs. It must be executed prior to running a build on Bazel and is only kept for legacy purposes. All new users should use `rbe_autoconfig`.

Refer to the documentation in rbe_repo.bzl and docker_config.bzl for more details of how to execute these rules
to pick/produce toolchain configs.

# Authentication

If you are generating toolchain configs for the first time, you will probably encounter permission
issues while `docker` is trying to talk to `gcr.io`.

If `gcloud` is installed, use `gcloud` as the Docker credential helper by following the instructions [here](https://cloud.google.com/sdk/gcloud/reference/auth/configure-docker). Otherwise, use `docker-credential-gcr` by following the instructions [here](https://github.com/GoogleCloudPlatform/docker-credential-gcr).
