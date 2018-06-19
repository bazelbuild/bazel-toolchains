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

# Install deb packages.
toolchain_container(
    name = "bazel",
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
        "//container/ubuntu16_04/layers/java:java-ltl",
        "//container/ubuntu16_04/layers/python:python-ltl",
        "//container/ubuntu16_04/layers/bazel:bazel-tools",
        "//container/ubuntu16_04/layers/bazel:bazel-ltl",
        "//container/ubuntu16_04/layers/git:git-ltl",
        "//container/ubuntu16_04/layers/wget:wget-ltl",
    ],
)

container_test(
    name = "bazel-test",
    configs = [
        ":container.yaml",
        "//container/common:java.yaml",
        "//container/common:python2.yaml",
        "//container/ubuntu16_04:ubuntu16_04.yaml",
        "//container/ubuntu16_04/layers/bazel:bazel.yaml",
        "//container/ubuntu16_04/layers/git:git.yaml",
        "//container/ubuntu16_04/layers/wget:wget.yaml",
    ],
    image = ":bazel",
    verbose = True,
)

# Install deb packages.
toolchain_container(
    name = "bazel_docker",
    base = ":bazel.tar",
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
        "//container/ubuntu16_04/layers/docker-17.12.0:docker-ltl",
    ],
)

container_test(
    name = "bazel_docker-test",
    configs = [
        ":container.yaml",
        "//container/common:java.yaml",
        "//container/common:python2.yaml",
        "//container/ubuntu16_04:ubuntu16_04.yaml",
        "//container/ubuntu16_04/layers/bazel:bazel.yaml",
        "//container/ubuntu16_04/layers/docker-17.12.0:docker-17.12.0.yaml",
        "//container/ubuntu16_04/layers/git:git.yaml",
        "//container/ubuntu16_04/layers/wget:wget.yaml",
    ],
    image = ":bazel_docker",
    verbose = True,
)
