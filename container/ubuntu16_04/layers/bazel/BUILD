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
load("//container/rules:docker_toolchains.bzl", "toolchain_container")
load("@base_images_docker//util:run.bzl", "container_run_and_extract")
load("//container/ubuntu16_04/layers/bazel:version.bzl", "BAZEL_VERSION")

exports_files(glob(["*.yaml"]))

# Tools required by Bazel. Note that we do not add a CC complier here as we
# will include that in the final container.
language_tool_layer(
    name = "bazel-tools",
    base = "@ubuntu16_04//image",
    packages = [
        "bash-completion",
        "binutils",
        "patch",
        "unzip",
        "zip",
    ],
)

toolchain_container(
    name = "bazel_installer_image",
    base = "@ubuntu16_04//image",
    files = [
        "@bazel_installer//file",
    ],
    packages = [
        "unzip",
    ],
)

container_run_and_extract(
    name = "bazel_tar",
    commands = [
        "cd /",
        "chmod +x bazel-" + BAZEL_VERSION + "-installer-linux-x86_64.sh",
        "./bazel-" + BAZEL_VERSION + "-installer-linux-x86_64.sh",
        "tar cvf bazel.tar /usr/local/bin/bazel /usr/local/lib/bazel/*",
    ],
    extract_file = "/bazel.tar",
    image = ":bazel_installer_image.tar",
)

language_tool_layer(
    name = "bazel-ltl",
    base = "@ubuntu16_04//image",
    tars = [":bazel_tar"],
)
