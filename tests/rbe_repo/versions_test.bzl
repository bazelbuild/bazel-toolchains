# Copyright 2016 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
""" Provides test definitions

Test file to validate behavior of rbe_autoconfig with export_configs
when repo is different to bazel-toolchains
"""

_ENV1 = {
    "key1": "value1",
    "key2": "value2",
}

_TOOLCHAIN_CONFIG_SPEC1 = struct(
    name = "testConfigSpecName1",
    java_home = "/usr/lib/jvm/java-8-openjdk-amd64",
    create_java_configs = True,
    create_cc_configs = True,
    config_repos = [],
    env = _ENV1,
)

_ENV2 = {
    "key3": "value3",
    "key4": "value4",
}

_TOOLCHAIN_CONFIG_SPEC2 = struct(
    name = "testConfigSpecName2",
    java_home = "/usr/lib/jvm/java-8-openjdk-amd64",
    create_java_configs = True,
    create_cc_configs = True,
    config_repos = [],
    env = _ENV2,
)

_TOOLCHAIN_CONFIG_SPECS = [_TOOLCHAIN_CONFIG_SPEC1, _TOOLCHAIN_CONFIG_SPEC2]

_DEFAULT_TOOLCHAIN_CONFIG_SPEC = _TOOLCHAIN_CONFIG_SPEC1

# A map from supported Bazel versions mapped to supported config_spec names.
_BAZEL_TO_CONFIG_SPEC_NAMES = {
    "0.24.0": ["testConfigSpecName1"],
    "0.25.0": ["testConfigSpecName2"],
    "0.26.0": ["testConfigSpecName2", "testConfigSpecName1"],
}

# sha256 digest of the latest version of the toolchain container.
LATEST = "sha256:94d7d8552902d228c32c8c148cc13f0effc2b4837757a6e95b73fdc5c5e4b07b"

# Map from sha256 of the toolchain container to corresponding major container
# versions.
CONTAINER_TO_CONFIG_SPEC_NAMES = {
    "sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375": ["testConfigSpecName1"],
    "sha256:94d7d8552902d228c32c8c148cc13f0effc2b4837757a6e95b73fdc5c5e4b07b": ["testConfigSpecName2", "testConfigSpecName1"],
}

TOOLCHAIN_CONFIG_AUTOGEN_SPEC = struct(
    bazel_to_config_spec_names_map = _BAZEL_TO_CONFIG_SPEC_NAMES,
    container_to_config_spec_names_map = CONTAINER_TO_CONFIG_SPEC_NAMES,
    default_toolchain_config_spec = _DEFAULT_TOOLCHAIN_CONFIG_SPEC,
    latest_container = LATEST,
    toolchain_config_specs = _TOOLCHAIN_CONFIG_SPECS,
)
