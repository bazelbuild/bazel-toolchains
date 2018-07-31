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
    "JDK_VERSION",
)

java_runtime(
    name = "jdk8",
    srcs = [],
    java_home = "/usr/lib/jvm/java-8-openjdk-amd64",
)

java_runtime(
    name = "jdk9",
    srcs = [],
    java_home = "/usr/lib/jvm/zulu" + JDK_VERSION + "-linux_x64",
)

# Latest RBE Debian8 container.
# Update every time when a new container is released.
alias(
    name = "rbe_debian8",
    actual = ":rbe_debian8_r328903",
)

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
            value:"docker://gcr.io/cloud-marketplace/google/rbe-debian8@sha256:0d5db936f8fa04638ca31e4fc117415068dca43dc343d605c0db2a15f433a327"
         }
         """,
)
