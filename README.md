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
