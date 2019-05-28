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

def configs():
    return []

DEFAULT_CONFIG = ""

# Returns a dict with suppported Bazel versions mapped to the config version to use.
def bazel_to_config_versions():
    return {
    }

# sha256 digest of the latest version of the toolchain container.
LATEST = ""

# Map from sha256 of the toolchain container to corresponding major container
# versions.
def container_to_config_versions():
    return {
    }

def versions():
    return struct(
        latest_container = LATEST,
        default_config = DEFAULT_CONFIG,
        rbe_repo_configs = configs,
        bazel_to_config_version_map = bazel_to_config_versions,
        container_to_config_version_map = container_to_config_versions,
    )
