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
    "output_base": "configs/test_configs",
    "container_repo": "google/bazel",
    "container_registry": "marketplace.gcr.io",
    "toolchain_config_suite_autogen_spec": TOOLCHAIN_CONFIG_AUTOGEN_SPEC,
}

CUSTOM_ENV1 = {"KEY1": "VALUE1"}
CUSTOM_ENV2 = {"KEY2": "VALUE2"}
CUSTOM_ENV3 = {"KEY3": "VALUE3"}

CUSTOM_BAZEL_VERSION1 = "0.24.0"
CUSTOM_BAZEL_VERSION2 = "0.25.0"
CUSTOM_BAZEL_VERSION3 = "0.26.0"

CUSTOM_BAZEL_DIGEST1 = "sha256:74bcb3dc68bf69a9c930fdb00e28e4c46bbb413a502ee45e8e3ca8a73f28dd3d"
CUSTOM_BAZEL_DIGEST2 = "sha256:3a608fe476a29237b08a50b3ad05604308b0154c8abd0bbf6809a89913cbeedc"
CUSTOM_BAZEL_DIGEST3 = "sha256:a2b4d40beb133924c3eaadb5b596fc0fbf3d8f30828deb99ecb3b305cc0ec38a"
