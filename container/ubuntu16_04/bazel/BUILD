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

load("//container/rules:docker_toolchains.bzl", "language_tool_layer", "toolchain_container")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_image",
)

language_tool_layer(
    name = "add-on-ltl",
    base = "@ubuntu16_04//image",
    packages = [
        "software-properties-common",
        "unzip",
        "git",
    ]
)

# Install deb packages.
toolchain_container(
    name = "toolchain_with_debs",
    base = "@ubuntu16_04//image",
    language_layers = [
        ":add-on-ltl",
        "//container/rbe-ubuntu16_04:java-ltl",
        "//container/rbe-ubuntu16_04:python-ltl",
        "//container/ubuntu16_04/layers/bazel:bazel-ltl",
        "//container/ubuntu16_04/layers/docker-17.12.0:docker-ltl",
    ],
)

# Setup other information, e.g. entrypoint.
container_image(
    name = "toolchain",
    base = ":toolchain_with_debs",
    entrypoint = ["bazel"],
)

container_test(
    name = "toolchain-test",
    configs = [
        ":container.yaml",
        "//container/ubuntu16_04/layers/bazel:bazel.yaml",
        "//container/ubuntu16_04/layers/docker-17.12.0:docker-17.12.0.yaml",
    ],
    # TODO(xingao) Test using :toolchain once rules_docker is updated with
    # latest version of the structure_test
    # https://github.com/bazelbuild/rules_docker/pull/416
    image = ":toolchain_with_debs",
)
