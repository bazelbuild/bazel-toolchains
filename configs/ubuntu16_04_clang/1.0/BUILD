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
    "//third_party/openjdk:revision.bzl",
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

# Latest RBE Ubuntu16_04 container
# Update every time when a new container is released.
alias(
    name = "rbe_ubuntu1604",
    actual = ":rbe_ubuntu1604_r328903",
)

# RBE Ubuntu16_04 r328903
platform(
    name = "rbe_ubuntu1604_r328903",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        "//constraints:xenial",
        "//constraints/sanitizers:support_msan",
    ],
    remote_execution_properties = """
          properties: {
            name: "container-image"
            value:"docker://gcr.io/cloud-marketplace/google/rbe-ubuntu16-04@sha256:59bf0e191a6b5cc1ab62c2224c810681d1326bad5a27b1d36c9f40113e79da7f"
         }
         """,
)

# Experimental ubuntu1604 based container with Docker.
platform(
    name = "nosla_xenial_docker",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        "//constraints:xenial",
        "//constraints/sanitizers:support_msan",
    ],
    remote_execution_properties = """
          properties: {
            name: "container-image"
            value:"docker://gcr.io/asci-toolchain/nosla-xenial-docker@sha256:780a96ba94b7666e31ba9a184e5a1742c3398250d47f5b87b1b4a60f8c41f164"
         }
         """,
)
