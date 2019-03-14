This directory contains YAML files which are used to define how to query the
latest available versions of dependencies for a particular toolchain config.

A single dependency specification file indicates the location of the Bazel
image used to determine the latest Bazel version and the toolchain container
used to determine the latest toolchain container version.

The following is an example YAML config for the RBE Ubuntu 16.04 container.
```yaml
# Location of the config-dependency tracker file on the repository
# specified in the Github spec YAML file to the toolchain configs update
# service.
revisionsFilePath: "configs/dependency-tracking/ubuntu16_04.yaml"
gcrDeps:
  # The RBE Ubuntu 16.04 toolchain container.
  - name: "IMAGE"
    location: "marketplace.gcr.io/google/rbe-ubuntu16-04"
    tag: "latest"
  # The Bazel container.
  - name: "BAZEL"
    location: "marketplace.gcr.io/google/bazel"
    tag: "latest"
```

