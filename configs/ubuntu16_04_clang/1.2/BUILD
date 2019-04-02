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
    name = "jdk11",
    srcs = [],
    java_home = "/usr/lib/jvm/11.29.3-ca-jdk11.0.2/reduced",
)

# This platform is used in CI for rules_docker and bazel-toolchains.
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
          value:"docker://gcr.io/asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud@sha256:ab88c40463d782acc4289948fe0b1577de0b143a753cea35cac34535203f8ca7"
        }
        properties: {
          name: "dockerSiblingContainers"
          value: "true"
        }
        properties: {
          name: "dockerNetwork"
          value: "standard"
        }
        """,
)

# Update every time when a new container is available publically.
LATEST_CLANG_VERSION = "r352865"

# Latest RBE Ubuntu16_04 container with JDK 11
alias(
    name = "rbe_ubuntu1604_jdk11",
    actual = ":rbe_ubuntu1604_" + LATEST_CLANG_VERSION + "_jdk1",
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
# to collect usage of JDK8 and JDK11.

# ====================== RBE Ubuntu16_04 r352865 targets ======================

# RBE Ubuntu16_04 r352865 with JDK 11
platform(
    name = "rbe_ubuntu1604_r352865_jdk11",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:da0f21c71abce3bbb92c3a0c44c3737f007a82b60f8bd2930abc55fe64fc2729"
        }
        properties: {
          name: "jdk-version"
          value:"11"
        }
        """,
)

# RBE Ubuntu16_04 r352865 with JDK 8
platform(
    name = "rbe_ubuntu1604_r352865_jdk8",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:da0f21c71abce3bbb92c3a0c44c3737f007a82b60f8bd2930abc55fe64fc2729"
        }
        properties: {
          name: "jdk-version"
          value:"8"
        }
        """,
)

# RBE Ubuntu16_04 r352865
platform(
    name = "rbe_ubuntu1604_r352865",
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
          value:"docker://marketplace.gcr.io/google/rbe-ubuntu16-04@sha256:da0f21c71abce3bbb92c3a0c44c3737f007a82b60f8bd2930abc55fe64fc2729"
        }
        """,
)
