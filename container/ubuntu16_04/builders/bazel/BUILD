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

load(
    "//container/rules:docker_toolchains.bzl",
    "language_tool_layer",
    "toolchain_container",
)
load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load("//container/common/bazel:version.bzl", "BAZEL_VERSION_SHA256S")

# Tools that are needed in most builds, but not strictly required by bazel.
language_tool_layer(
    name = "extra-tools-ltl",
    base = "@ubuntu16_04//image",
    packages = [
        "git",
        "wget",
    ],
)

# Generate the Bazel container for all supported versions using the
# corresponding Bazel language_tool_layer targets.
[toolchain_container(
    name = "bazel_%s_intermediate" % bazel_version,
    base = "@ubuntu16_04//image",
    # TODO(xingao) Fix this. We should not remove /etc/ssl/certs/java/cacerts
    # file in the java-ltl, but instead, archive it for future container
    # reproduction.
    installation_cleanup_commands = "update-ca-certificates -f",
    language_layers = [
        ":extra-tools-ltl",
        "//container/ubuntu16_04/layers/clang:clang-ltl",
        "//container/ubuntu16_04/layers/java:java-ltl",
        "//container/ubuntu16_04/layers/java:java10-ltl",
        "//container/ubuntu16_04/layers/python:python-ltl",
        "//container/ubuntu16_04/layers/bazel:bazel-tools",
        "//container/ubuntu16_04/layers/bazel:bazel_%s-ltl" % bazel_version,
    ],
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]

# Set up `entrypoint` and cmd in the container. These cannot be down in the
# `toolchain_container` rule as they would be consumed by intermediate
# `container_image` rule in its implementation.
# TODO(xingao): enable setting things like `entrypoint` and `cmd` in
# `toolchain_container`.
[container_image(
    name = "bazel_%s" % bazel_version,
    base = ":bazel_%s_intermediate" % bazel_version,
    cmd = None,
    entrypoint = ["/usr/local/bin/bazel"],
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]

# container_test targets for all supported Bazel versions.
[container_test(
    name = "bazel_%s-test" % bazel_version,
    configs = [
        ":container.yaml",
        "//container/common:java.yaml",
        "//container/common:python2.yaml",
        "//container/common/clang:clang.yaml",
        "//container/common/bazel:bazel_%s.yaml" % bazel_version,
        "//container/common/bazel:bazel_tools.yaml",
        "//container/common/bazel:extra_tools.yaml",
        "//container/ubuntu16_04:ubuntu16_04.yaml",
    ],
    image = ":bazel_%s" % bazel_version,
    verbose = True,
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]
