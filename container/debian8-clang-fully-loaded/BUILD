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

load("@distroless//cacerts:cacerts.bzl", "cacerts")
load("@jessie_package_bundle//file:packages.bzl", "packages")
load(
    "//container/rules:docker_toolchains.bzl",
    "language_tool_layer",
    "toolchain_container",
)
load(
    "//skylib:packages.bzl",
    "base_layer_packages",
    "clang_layer_packages",
    "java_layer_packages",
    "python_layer_packages",
)

cacerts(
    name = "cacerts",
    deb = packages["ca-certificates"],
)

toolchain_container(
    name = "fl-toolchain",
    base = "@debian8//image",
    env = {
        # PATH envvar is a special case, and currently only the one in the
        # topmost layer is set. So that we override it here to include all.
        "PATH": "/usr/local/go/bin:/opt/python3.6/bin:$PATH",
    },
    layers = [
        "base-ltl",
        "clang-ltl",
        "go-ltl",
        "java-ltl",
        "python-ltl",
    ],
    tags = ["manual"],
)

language_tool_layer(
    name = "base-ltl",
    base = "@debian8//image",
    debs = base_layer_packages(),
    tags = ["manual"],
    tars = [
        ":cacerts.tar",
    ],
)

language_tool_layer(
    name = "clang-ltl",
    base = "@debian8//image",
    debs = clang_layer_packages(),
    env = {
        "CC": "/usr/local/bin/clang",
    },
    tags = ["manual"],
    tars = ["//third_party/clang:tar"],
)

language_tool_layer(
    name = "go-ltl",
    base = "@debian8//image",
    env = {
        "GOPATH": "/go",
        "PATH": "$PATH:/usr/local/go/bin",
    },
    tags = ["manual"],
    tars = ["@golang_release//:tar"],
)

language_tool_layer(
    name = "java-ltl",
    base = "@debian8//image",
    debs = java_layer_packages(),
    env = {
        "JAVA_HOME": "/usr/lib/jvm/java-8-openjdk-amd64",
    },
    symlinks = {
        "/usr/bin/java": "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java",
    },
    tags = ["manual"],
)

language_tool_layer(
    name = "python-ltl",
    base = "@debian8//image",
    debs = python_layer_packages(),
    env = {
        "PATH": "$PATH:/opt/python3.6/bin",
    },
    symlinks = {
        "/usr/bin/python": "/usr/bin/python2.7",
    },
    tags = ["manual"],
)
