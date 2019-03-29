This directory contains Starlark files which are used to track dependencies for
configs generated for specific RBE toolchain containers.

A single dependency tracking file indicates the latest bazel version and
toolchain container the corresponding toolchain configs were last generated for.
When a new bazel versions or toolchain container version is available, the
dependency tracking file will be automatically updated by the config dependency
update service. This in turn will trigger a GCB build to generate the new
configs.

The following is an example Starlark file for the RBE Ubuntu 16.04 container.
```python
# The version of Bazel.
bazel = "0.21.0"
# The registry the toolchain container resides on.
registry = "marketplace.gcr.io"
# The repository path to the toolchain container.
repository = "google/rbe-ubuntu16-04"
# The sha256 digest of the toolchain container.
digest = "sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375"
# The version of the configs.
configs_version = "7.0.0"
```

Note: Comments in the Starlark files will not be preserved by the dependency
update service.
