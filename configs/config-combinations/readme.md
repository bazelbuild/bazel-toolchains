This directory containers YAML files which are config combinations for various
RBE toolchain containers.
A config combination file indicates the latest bazel version and toolchain 
container the corresponding toolchain configs were last generated for. When 
newer bazel versions or toolchain containers are available, the config 
combination file will be automatically updated by the config dependency update 
service. This in turn will trigger a GCB build to generate the new configs.

The following is an example YAML config for the RBE Ubuntu 16.04 container.
```yaml
# Latest bazel version configs were generated for.
bazel: "0.21.0"

# Digest of the latest ubuntu 16.04 toolchain container image.
digest: "f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375"
```

Note: Comments in the YAML configs will not be preserved by the dependency
update service.
