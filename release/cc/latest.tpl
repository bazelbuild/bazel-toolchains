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

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

# This file is auto-generated from release/cc/latest.tpl and should not
# be modified directly.

PACKAGE = "//${PACKAGE}/"

LATEST_CONFIG_VERSION = "${CONFIG_VERSION}"

LATEST_BAZEL_VERSION = "${BAZEL_VERSION}"

CONFIG_TYPES = [${CONFIG_TYPES}]

# DO NOT depend on the following latest alias in your production jobs.
# These are for internal and our CI use only. We DO NOT guarantee that they
# will always work.
[alias(
    name = "crosstool_top_" + config_type,
    actual = PACKAGE + LATEST_CONFIG_VERSION + "/bazel_" + LATEST_BAZEL_VERSION + "/" + config_type + ":toolchain",
) for config_type in CONFIG_TYPES]

[alias(
    name = "toolchain_" + config_type,
    actual = PACKAGE + LATEST_CONFIG_VERSION + "/bazel_" + LATEST_BAZEL_VERSION + "/cpp:cc-toolchain-clang-x86_64-" + config_type,
) for config_type in CONFIG_TYPES]

alias(
    name = "platform",
    actual = PACKAGE + LATEST_CONFIG_VERSION + ":${PLATFORM}_jdk8",
)

alias(
    name = "javabase",
    actual = PACKAGE + LATEST_CONFIG_VERSION + ":jdk8",
)

# For internal testing purpose only.
toolchain(
    name = "toolchain_docker",
    exec_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//tools/cpp:clang",
        "//constraints:support_docker",
        ${EXTRA_CONSTRAINTS}
    ],
    target_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
    ],
    toolchain = PACKAGE + LATEST_CONFIG_VERSION + "/bazel_" + LATEST_BAZEL_VERSION + "/default:cc-compiler-k8",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

# For internal testing purpose only.
alias(
    name = "platform_docker",
    actual = PACKAGE + LATEST_CONFIG_VERSION + ":nosla_xenial_docker",
)
