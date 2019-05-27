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

env1 = {
    "key1": "value1",
    "key2": "value2",
}
config1 = struct(
    name = "test024config",
    java_home = "/usr/lib/jvm/java-8-openjdk-amd64",
    create_java_configs = True,
    create_cc_configs = True,
    config_repos = [],
    env = env1,
)

env2 = {
    "key3": "value3",
    "key4": "value4",
}
config2 = struct(
    name = "test025config",
    java_home = "/usr/lib/jvm/java-8-openjdk-amd64",
    create_java_configs = True,
    create_cc_configs = True,
    config_repos = [],
    env = env2,
)

def configs():
    return [config1, config2]

DEFAULT_CONFIG = config1

# Returns a dict with suppported Bazel versions mapped to the config version to use.
def bazel_to_config_versions():
    return {
        "0.24.0": ["test024config"],
        "0.25.0": ["test025config"],
    }

# sha256 digest of the latest version of the toolchain container.
LATEST = "sha256:94d7d8552902d228c32c8c148cc13f0effc2b4837757a6e95b73fdc5c5e4b07b"

# Map from sha256 of the toolchain container to corresponding major container
# versions.
def container_to_config_version():
    return {
        "sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375": ["test024config"],
        "sha256:94d7d8552902d228c32c8c148cc13f0effc2b4837757a6e95b73fdc5c5e4b07b": ["test025config"],
    }
