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

# Constraints used in configuring the remote platforms and toolchains.
constraint_setting(name = "linux_distribution")

constraint_value(
    name = "jessie",
    constraint_setting = ":linux_distribution",
)

constraint_value(
    name = "xenial",
    constraint_setting = ":linux_distribution",
)

# RBE Debian8
platform(
    name = "rbe_debian8",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        ":jessie",
    ],
    remote_execution_properties = """
          properties: {
            name: "container-image"
            value:"docker://gcr.io/cloud-marketplace/google/rbe-ubuntu16-04@sha256:59bf0e191a6b5cc1ab62c2224c810681d1326bad5a27b1d36c9f40113e79da7f"
         }
         """,
)

# RBE Ubuntu16.04
platform(
    name = "rbe_ubuntu16_04",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        ":xenial",
    ],
    remote_execution_properties = """
          properties: {
            name: "container-image"
            value:"docker://gcr.io/cloud-marketplace/google/rbe-ubuntu16-04@sha256:59bf0e191a6b5cc1ab62c2224c810681d1326bad5a27b1d36c9f40113e79da7f"
         }
         """,
)
