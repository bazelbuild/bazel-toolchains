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
# limitations under the License.

package(default_visibility = ["//visibility:public"])

load(
    "@bazel_toolchains//third_party/openjdk:revision.bzl",
    JDK_VERSION = "JDK_VERSION_DECODED",
)

java_runtime(
    name = "jdk8",
    srcs = [],
    java_home = "/usr/lib/jvm/java-8-openjdk-amd64",
)

java_runtime(
    name = "jdk10",
    srcs = [],
    java_home = "/usr/lib/jvm/zulu" + JDK_VERSION + "-linux_x64-allmodules",
)

toolchain(
    name = "cc-toolchain",
    exec_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//tools/cpp:clang",
    ],
    target_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
    ],
    toolchain = "%{toolchain}:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

alias(
    name = "rbe_ubuntu1604",
    actual = ":rbe_ubuntu1604_%{revision}",
)

platform(
    name = "rbe_ubuntu1604_%{revision}",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
    ],
    remote_execution_properties = """
        properties: {
          name: "container-image"
          value:"docker://gcr.io/cloud-marketplace/google/rbe-ubuntu16-04@%{rbe_ubuntu16_04_sha256}"
        }
        """,
)
