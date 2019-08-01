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

load(":versions.bzl", "TOOLCHAIN_CONFIG_AUTOGEN_SPEC")

CUSTOM_TOOLCHAIN_CONFIG_SUITE_SPEC = {
    "repo_name": "toolchain_config_host",
    "output_base": "configs/test_configs_no_java",
    "container_repo": "google/bazel",
    "container_registry": "marketplace.gcr.io",
    "toolchain_config_suite_autogen_spec": TOOLCHAIN_CONFIG_AUTOGEN_SPEC,
}
