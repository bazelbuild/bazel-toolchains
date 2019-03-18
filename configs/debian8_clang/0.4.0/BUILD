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
LATEST_CLANG_VERSION = "r346485"

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

# ======================== RBE Debian8 r340178 targets ========================

# RBE Debian8 r340178 with JDK 10
platform(
    name = "rbe_debian8_r340178_jdk10",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:75ba06b78aa99e58cfb705378c4e3d6f0116052779d00628ecb73cd35b5ea77d"
        }
        properties: {
          name: "jdk-version"
          value:"10"
        }
        """,
)

# RBE Debian8 r340178 with JDK 8
platform(
    name = "rbe_debian8_r340178_jdk8",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:75ba06b78aa99e58cfb705378c4e3d6f0116052779d00628ecb73cd35b5ea77d"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Debian8 r340178
platform(
    name = "rbe_debian8_r340178",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:75ba06b78aa99e58cfb705378c4e3d6f0116052779d00628ecb73cd35b5ea77d"
        }
        """,
)

# ======================== RBE Debian8 r342117 targets ========================

# RBE Debian8 r342117 with JDK 10
platform(
    name = "rbe_debian8_r342117_jdk10",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:4893599fb00089edc8351d9c26b31d3f600774cb5addefb00c70fdb6ca797abf"
        }
        properties: {
          name: "jdk-version"
          value:"10"
        }
        """,
)

# RBE Debian8 r342117 with JDK 8
platform(
    name = "rbe_debian8_r342117_jdk8",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:4893599fb00089edc8351d9c26b31d3f600774cb5addefb00c70fdb6ca797abf"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Debian8 r342117
platform(
    name = "rbe_debian8_r342117",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:4893599fb00089edc8351d9c26b31d3f600774cb5addefb00c70fdb6ca797abf"
        }
        """,
)

# ======================== RBE Debian8 r346485 targets ========================

# RBE Debian8 r346485 with JDK 10
platform(
    name = "rbe_debian8_r346485_jdk10",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:cda3a8608d0fc545dffc6c68f6cfab8eda280c7a1558bde0753ed2e8e3006224"
        }
        properties: {
          name: "jdk-version"
          value:"10"
        }
        """,
)

# RBE Debian8 r346485 with JDK 8
platform(
    name = "rbe_debian8_r346485_jdk8",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:cda3a8608d0fc545dffc6c68f6cfab8eda280c7a1558bde0753ed2e8e3006224"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Debian8 r346485
platform(
    name = "rbe_debian8_r346485",
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
          value:"docker://marketplace.gcr.io/google/rbe-debian8@sha256:cda3a8608d0fc545dffc6c68f6cfab8eda280c7a1558bde0753ed2e8e3006224"
        }
        """,
)
