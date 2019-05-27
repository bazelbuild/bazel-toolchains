# Copyright 2017 The Bazel Authors. All rights reserved.
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
# limitations under the License.
""" Definitions for a custom rbe_repo."""

load(
    ":versions.bzl",
    rbe_custom_config = "DEFAULT_CONFIG",
    rbe_custom_latest = "LATEST",
)

CUSTOM_RBE_REPO = {
    "repo_name": "toolchain_config_host",
    "output_base": "configs/test_configs",
    "container_repo": "google/bazel",
    "container_registry": "marketplace.gcr.io",
    "latest_container": rbe_custom_latest,
    "default_config": rbe_custom_config,
}

CUSTOM_ENV1 = {"KEY1": "VALUE1"}
CUSTOM_ENV2 = {"KEY2": "VALUE2"}
CUSTOM_ENV3 = {"KEY3": "VALUE3"}
