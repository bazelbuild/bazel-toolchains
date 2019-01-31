This directory contains YAML files which are used to track dependencies for 
configs generated for specific RBE toolchain containers.

A single dependency tracking file indicates the latest bazel version and 
toolchain container the corresponding toolchain configs were last generated for. 
When a new bazel versions or toolchain container version is available, the 
dependency tracking file will be automatically updated by the config dependency 
update service. This in turn will trigger a GCB build to generate the new 
configs.

The following is an example YAML config for the RBE Ubuntu 16.04 container.
```yaml
# Latest bazel version configs were generated for.
bazel: "0.21.0"

# Config version
version: "7.0.0-r342117"
```

Note: Comments in the YAML configs will not be preserved by the dependency
update service.
