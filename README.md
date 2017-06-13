# bazel-toolchains

https://github.com/bazelbuild/bazel-toolchains is a repository where Google
hosts Bazel configuration artifacts. These artifacts are required to configure
Bazel to issue commands that will execute inside a Docker container via a remote
execution environment.

These artifacts include the C/C++ CROSSTOOL file, BUILD files with toolchain
rules, wrapper scripts, and necessary signature files for validating the files
in this repository.

This repository also hosts the skylark rule used to generate toolchain
artifacts.
