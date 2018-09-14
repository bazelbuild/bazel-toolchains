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
load("//container/common/bazel:version.bzl", "BAZEL_VERSION_SHA256S")

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

# Create image with Bazel installer for all supported versions.
[toolchain_container(
    name = "bazel_%s_installer_image" % bazel_version,
    base = "@ubuntu16_04//image",
    files = [
        "@bazel_%s_installer//file" % bazel_version.replace(".", ""),
        "//container/common/bazel:bazel.bazelrc",
    ],
    packages = [
        "unzip",
    ],
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]

# Extract Bazel binaries for all supported versions.
[container_run_and_extract(
    name = "bazel_%s_tar" % bazel_version,
    commands = [
        "mv /bazel.bazelrc /etc/bazel.bazelrc",
        "chmod +x /bazel-%s-installer-linux-x86_64.sh" % bazel_version,
        "/bazel-%s-installer-linux-x86_64.sh" % bazel_version,
        "tar cvf /bazel.tar --mtime='1970-01-01' /usr/local/bin/bazel /usr/local/lib/bazel/* /etc/bazel.bazelrc",
    ],
    extract_file = "/bazel.tar",
    image = ":bazel_%s_installer_image.tar" % bazel_version,
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]

# Language_tool_layer targets for all supported Bazel versions.
[language_tool_layer(
    name = "bazel_%s-ltl" % bazel_version,
    base = "@ubuntu16_04//image",
    tars = [":bazel_%s_tar" % bazel_version],
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]
