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

java_runtime(
    name = "jdk11",
    srcs = [],
    java_home = "/usr/lib/jvm/11.29.3-ca-jdk11.0.2/reduced",
)

# Update every time when a new container is available publically.
LATEST_CLANG_VERSION = "r346485"

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

# ====================== RBE Ubuntu16_04 r340178 targets ======================

# RBE Ubuntu16_04 r340178 with JDK 10
platform(
    name = "rbe_ubuntu1604_r340178_jdk10",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:9bd8ba020af33edb5f11eff0af2f63b3bcb168cd6566d7b27c6685e717787928"
        }
        properties: {
          name: "jdk-version"
          value:"10"
        }
        """,
)

# RBE Ubuntu16_04 r340178 with JDK 8
platform(
    name = "rbe_ubuntu1604_r340178_jdk8",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:9bd8ba020af33edb5f11eff0af2f63b3bcb168cd6566d7b27c6685e717787928"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Ubuntu16_04 r340178
platform(
    name = "rbe_ubuntu1604_r340178",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:9bd8ba020af33edb5f11eff0af2f63b3bcb168cd6566d7b27c6685e717787928"
        }
        """,
)

# Experimental ubuntu1604 based container with Docker.
# Based on marketplace.gcr.io/google/rbe-ubuntu16-04:r340178
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
          value:"docker://gcr.io/asci-toolchain/nosla-xenial-docker@sha256:b4f34255823ae7f95f38712b85013ec26926c8c5b565b0d3f1d32e1295394e9d"
        }
        properties: {
          name: "dockerSiblingContainers"
          value: "true"
        }
        """,
)

# ====================== RBE Ubuntu16_04 r342117 targets ======================

# RBE Ubuntu16_04 r342117 with JDK 10
platform(
    name = "rbe_ubuntu1604_r342117_jdk10",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375"
        }
        properties: {
          name: "jdk-version"
          value:"10"
        }
        """,
)

# RBE Ubuntu16_04 r342117 with JDK 8
platform(
    name = "rbe_ubuntu1604_r342117_jdk8",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Ubuntu16_04 r342117
platform(
    name = "rbe_ubuntu1604_r342117",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375"
        }
        """,
)

# ====================== RBE Ubuntu16_04 r346485 targets ======================

# RBE Ubuntu16_04 r346485 with JDK 10
platform(
    name = "rbe_ubuntu1604_r346485_jdk10",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c"
        }
        properties: {
          name: "jdk-version"
          value:"10"
        }
        """,
)

# RBE Ubuntu16_04 r346485 with JDK 8
platform(
    name = "rbe_ubuntu1604_r346485_jdk8",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Ubuntu16_04 r346485
platform(
    name = "rbe_ubuntu1604_r346485",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c"
        }
        """,
)
