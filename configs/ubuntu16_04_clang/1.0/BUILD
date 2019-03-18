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

java_runtime(
    name = "jdk8",
    srcs = [],
    java_home = "/usr/lib/jvm/java-8-openjdk-amd64",
)

java_runtime(
    name = "jdk10",
    srcs = [],
    java_home = "/usr/lib/jvm/zulu10.2+3-jdk10.0.1-linux_x64-allmodules",
)

# Update every time when a new container is available publically.
LATEST_CLANG_VERSION = "r337145"

# Latest RBE Ubuntu16_04 container with JDK 10
alias(
    name = "rbe_ubuntu1604_jdk10",
    actual = ":rbe_ubuntu1604_" + LATEST_CLANG_VERSION + "_jdk10",
)

# Latest RBE Ubuntu16_04 container with JDK 8
alias(
    name = "rbe_ubuntu1604_jdk8",
    actual = ":rbe_ubuntu1604_" + LATEST_CLANG_VERSION + "_jdk8",
)

# Latest RBE Ubuntu16_04 container
alias(
    name = "rbe_ubuntu1604",
    actual = ":rbe_ubuntu1604_" + LATEST_CLANG_VERSION,
)

# We use an additional remote_execution_propertie called "jdk-version" to
# to collect usage of JDK8 and JDK10.

# ====================== RBE Ubuntu16_04 r337145 targets ======================

# RBE Ubuntu16_04 r337145 with JDK 10
platform(
    name = "rbe_ubuntu1604_r337145_jdk10",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:b348b2e63253d5e2d32613a349747f07dc82b6b1ecfb69e8c7ac81a653b857c2"
        }
        properties: {
          name: "jdk-version"
          value:"10"
        }
        """,
)

# RBE Ubuntu16_04 r337145 with JDK 8
platform(
    name = "rbe_ubuntu1604_r337145_jdk8",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:b348b2e63253d5e2d32613a349747f07dc82b6b1ecfb69e8c7ac81a653b857c2"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Ubuntu16_04 r337145
platform(
    name = "rbe_ubuntu1604_r337145",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:b348b2e63253d5e2d32613a349747f07dc82b6b1ecfb69e8c7ac81a653b857c2"
        }
        """,
)

# ====================== RBE Ubuntu16_04 r328903 targets ======================

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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:59bf0e191a6b5cc1ab62c2224c810681d1326bad5a27b1d36c9f40113e79da7f"
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
        "//constraints:support_docker",
        "//constraints:xenial",
        "//constraints/sanitizers:support_msan",
    ],
    remote_execution_properties = """
        properties: {
          name: "container-image"
          value:"docker://gcr.io/asci-toolchain/nosla-xenial-docker@sha256:780a96ba94b7666e31ba9a184e5a1742c3398250d47f5b87b1b4a60f8c41f164"
        }
        properties: {
          name: "dockerSiblingContainers"
          value: "true"
        }
        """,
)
