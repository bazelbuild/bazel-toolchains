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

# Latest RBE Debian8 container with JDK10
alias(
    name = "rbe_debian8_jdk10",
    actual = ":rbe_debian8_" + LATEST_CLANG_VERSION + "_jdk10",
)

# Latest RBE Debian8 container with JDK8
alias(
    name = "rbe_debian8_jdk8",
    actual = ":rbe_debian8_" + LATEST_CLANG_VERSION + "_jdk8",
)

# Latest RBE Debian8 container
alias(
    name = "rbe_debian8",
    actual = ":rbe_debian8_" + LATEST_CLANG_VERSION,
)

# We use an additional remote_execution_propertie called "jdk-version" to
# to collect usage of JDK8 and JDK10.

# ======================== RBE Debian8 r337145 targets ========================

# RBE Debian8 r337145 with JDK 10
platform(
    name = "rbe_debian8_r337145_jdk10",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        "//constraints/sanitizers:support_msan",
        "//constraints:jessie",
    ],
    remote_execution_properties = """
        properties: {
          name: "container-image"
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:46c4fd30ed413f16a8be697833f7c07997c61997c0dceda651e9167068ca2cd3"
        }
        properties: {
          name: "jdk-version"
          value:"10"
        }
        """,
)

# RBE Debian8 r337145 with JDK 8
platform(
    name = "rbe_debian8_r337145_jdk8",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        "//constraints/sanitizers:support_msan",
        "//constraints:jessie",
    ],
    remote_execution_properties = """
        properties: {
          name: "container-image"
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:46c4fd30ed413f16a8be697833f7c07997c61997c0dceda651e9167068ca2cd3"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Debian8 r337145
platform(
    name = "rbe_debian8_r337145",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        "//constraints/sanitizers:support_msan",
        "//constraints:jessie",
    ],
    remote_execution_properties = """
        properties: {
          name: "container-image"
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:46c4fd30ed413f16a8be697833f7c07997c61997c0dceda651e9167068ca2cd3"
        }
        """,
)

# ======================== RBE Debian8 r328903 targets ========================

# RBE Debian8 r328903
platform(
    name = "rbe_debian8_r328903",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        "//constraints/sanitizers:support_msan",
        "//constraints:jessie",
    ],
    remote_execution_properties = """
        properties: {
          name: "container-image"
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:0d5db936f8fa04638ca31e4fc117415068dca43dc343d605c0db2a15f433a327"
        }
        """,
)
