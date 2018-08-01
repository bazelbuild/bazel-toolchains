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

load("//container/rules:docker_toolchains.bzl", "toolchain_container")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load("//container/ubuntu16_04/layers/bazel:version.bzl", "BAZEL_VERSION_SHA256S")

# Generate the Bazel container for all supported versions using the
# corresponding Bazel language_tool_layer targets.
[toolchain_container(
    name = "bazel_%s" % bazel_version,
    base = "@ubuntu16_04//image",
    cmd = [
        "/bin/sh",
        "-c",
        "/bin/bash",
    ],
    # TODO(xingao) Fix this. We should not remove /etc/ssl/certs/java/cacerts
    # file in the java-ltl, but instead, archive it for future container
    # reproduction.
    installation_cleanup_commands = "update-ca-certificates -f",
    language_layers = [
        "//container/ubuntu16_04/layers/clang:clang-ltl",
        "//container/ubuntu16_04/layers/java:java-ltl",
        "//container/ubuntu16_04/layers/java:java10-ltl",
        "//container/ubuntu16_04/layers/python:python-ltl",
        "//container/ubuntu16_04/layers/bazel:bazel-tools",
        "//container/ubuntu16_04/layers/bazel:bazel_%s-ltl" % bazel_version,
        "//container/ubuntu16_04/layers/git:git-ltl",
        "//container/ubuntu16_04/layers/wget:wget-ltl",
    ],
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]

# container_test targets for all supported Bazel versions.
[container_test(
    name = "bazel_%s-test" % bazel_version,
    configs = [
        ":container.yaml",
        "//container/common:clang.yaml",
        "//container/common:git.yaml",
        "//container/common:java.yaml",
        "//container/common:python2.yaml",
        "//container/common:wget.yaml",
        "//container/ubuntu16_04:ubuntu16_04.yaml",
        "//container/ubuntu16_04/layers/bazel:bazel_%s.yaml" % bazel_version,
        "//container/ubuntu16_04/layers/bazel:bazel_tools.yaml",
    ],
    image = ":bazel_%s" % bazel_version,
    verbose = True,
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]
