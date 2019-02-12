This directory contains YAML files which are used to define how to query the
latest available versions of dependencies for a particular toolchain config.

A single dependency specification file indicates the location of the Bazel
image used to determine the latest Bazel version and the toolchain container
used to determine the latest toolchain container version.

The following is an example YAML config for the RBE Ubuntu 16.04 container.
```yaml
gcrDeps:
  - name: "IMAGE"
    location: "l.gcr.io/google/rbe-ubuntu16-04"
    tag: "latest"
  - name: "BAZEL"
    location: "l.gcr.io/google/bazel"
    tag: "latest"
```

