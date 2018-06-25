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

load("//container/rules:docker_toolchains.bzl", "language_tool_layer")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

exports_files(glob(["*.yaml"]))

# Tools required by Bazel. Note that we do not add a CC complier here as we
# will include that in the final container.
language_tool_layer(
    name = "bazel-tools",
    base = "@ubuntu16_04//image",
    packages = [
        "patch",
        "unzip",
        "zip",
    ],
)

pkg_tar(
    name = "bazel-package",
    srcs = [
        "@bazel_0141_release//file",
    ],
    tags = ["manual"],
)

language_tool_layer(
    name = "bazel-ltl",
    base = "@ubuntu16_04//image",
    installables_tar = ":bazel-package.tar",
)
