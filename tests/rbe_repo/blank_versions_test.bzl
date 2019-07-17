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
when repo is initially set up
"""

_TOOLCHAIN_CONFIG_SPECS = []

_DEFAULT_TOOLCHAIN_CONFIG_SPEC = ""

# A map from supported Bazel versions mapped to supported config_spec names.
_BAZEL_TO_CONFIG_SPEC_NAMES = {}

# sha256 digest of the latest version of the toolchain container.
LATEST = ""

# Map from sha256 of the toolchain container to corresponding config_spec names.
CONTAINER_TO_CONFIG_SPEC_NAMES = {}

TOOLCHAIN_CONFIG_AUTOGEN_SPEC = struct(
    bazel_to_config_spec_names_map = _BAZEL_TO_CONFIG_SPEC_NAMES,
    container_to_config_spec_names_map = CONTAINER_TO_CONFIG_SPEC_NAMES,
    default_toolchain_config_spec = _DEFAULT_TOOLCHAIN_CONFIG_SPEC,
    latest_container = LATEST,
    toolchain_config_specs = _TOOLCHAIN_CONFIG_SPECS,
)
