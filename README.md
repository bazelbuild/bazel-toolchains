Bazel CI
:---:
[![Build status](https://badge.buildkite.com/940075452c1c5ff91dc832664c4c8f05e6ec736916688cd894.svg?branch=master)](https://buildkite.com/bazel/bazel-toolchains-postsubmit)

# bazel-toolchains

https://github.com/bazelbuild/bazel-toolchains is a repository where Google
hosts Bazel toolchain configs. These configs are required to configure
Bazel to issue commands that will execute inside a Docker container via a remote
execution environment.

These toolchain configs include:
* C/C++ CROSSTOOL file,
* BUILD file with toolchain rules, and
* wrapper scripts.

Release information of toolchain configs can be found at:
https://releases.bazel.build/bazel-toolchains.html.

This repository also hosts the skylark rule used to generate toolchain configs.

This repo previously contained Bazel targets that are used to generate toolchain
containers. Note that they have been migrated to the following two repos:
* [layer-definitions](https://github.com/GoogleCloudPlatform/layer-definitions)
* [container-definitions](https://github.com/GoogleCloudPlatform/container-definitions)
