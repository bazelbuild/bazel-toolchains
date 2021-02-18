Bazel CI
:---:
[![Build status](https://badge.buildkite.com/940075452c1c5ff91dc832664c4c8f05e6ec736916688cd894.svg?branch=master)](https://buildkite.com/bazel/bazel-toolchains-postsubmit)

# bazel-toolchains

https://github.com/bazelbuild/bazel-toolchains is a repository where Google
hosts the source code for a CLI tool that can be used to generate Bazel toolchain configs. These 
configs are required to configure Bazel to issue commands that will execute inside a Docker 
container via a remote execution environment.

These toolchain configs include:
* C/C++ CROSSTOOL file,
* BUILD file with toolchain rules, and
* wrapper scripts.

# rbe_configs_gen - CLI Tool to Generate Configs

[rbe_configs_gen](https://github.com/bazelbuild/bazel-toolchains/blob/master/cmd/rbe_configs_gen/rbe_configs_gen.go) is the
new CLI tool written in Go that can be used to generate toolchain configs for a given combination
of Bazel release and docker image. The output of the tool are toolchain configs in one or more of
the following formats:
* Tarball
* Config files copied directly to a local directory

Config users are recommended to use the CLI tool to generate and self host their own configs.
Pre-generated configs will be provided for new releases of Bazel & the [RBE Ubuntu 16.04](https://console.cloud.google.com/marketplace/details/google/rbe-ubuntu16-04)
without any SLOs. See [Pre-generated Configs]() section below for details.

The rest of this section describes how to use the rbe_configs_gen tool.

## Building

## Generating Configs - Latest Bazel Version & Output Tarball

## Generating Configs - Specific Bazel Version & Output Directory

## Using Configs - Remote Tarball Archive

## Using Configs - Remote Github Repository

# Pre-generated Configs

# Where is rbe_autoconfig?

The [rbe_autoconfig](https://github.com/bazelbuild/bazel-toolchains/blob/4.0.0/rules/rbe_repo.bzl#L896) 
Bazel repository rule used to generate & use toolchain configs has been deprecated with release
[v4.0.0](https://github.com/bazelbuild/bazel-toolchains/releases/tag/4.0.0) of this repository
being the last release that supports rbe_autoconfig. Release v4.0.0 supports Bazel versions up to
[4.0.0](https://github.com/bazelbuild/bazel/releases/tag/4.0.0).
