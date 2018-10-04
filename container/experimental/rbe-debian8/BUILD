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
    "@bazel_toolchains//skylib:packages.bzl",
    "base_layer_packages",
    "clang_layer_packages",
    "java_layer_packages",
    "python_layer_packages",
)
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_image",
    "container_layer",
)
load("//container/common/clang:clang.bzl", "clang_env")

cacerts(
    name = "cacerts",
    deb = packages["ca-certificates"],
)

container_image(
    name = "toolchain",
    base = "@debian8//image",
    cmd = [
        "/bin/sh",
        "-c",
        "/bin/bash",
    ],
    env = {
        "LANG": "C.UTF-8",
        "LANGUAGE": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
    },
    layers = [
        "base-ltl",
        "clang-ltl",
        "python-ltl",
        "go-ltl",
        "java-ltl",
    ],
    tags = ["manual"],
)

container_layer(
    name = "base-ltl",
    debs = base_layer_packages(),
    tags = ["manual"],
    tars = [
        ":cacerts.tar",
    ],
)

container_layer(
    name = "clang-ltl",
    debs = clang_layer_packages(),
    env = clang_env,
    tags = ["manual"],
    tars = [
        "//third_party/clang:debian8_tar",
        "//third_party/libcxx:debian8_tar",
    ],
)

container_layer(
    name = "go-ltl",
    env = {
        "GOPATH": "/go",
        "PATH": "$PATH:/usr/local/go/bin",
    },
    tags = ["manual"],
    tars = ["//third_party/golang:tar"],
)

container_layer(
    name = "java-ltl",
    debs = java_layer_packages(),
    env = {
        "JAVA_HOME": "/usr/lib/jvm/java-8-openjdk-amd64",
    },
    symlinks = {
        "/usr/bin/java": "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java",
    },
    tags = ["manual"],
)

container_layer(
    name = "python-ltl",
    debs = python_layer_packages(),
    env = {
        "PATH": "$PATH:/opt/python3.6/bin",
    },
    symlinks = {
        "/usr/bin/python": "/usr/bin/python2.7",
        "/usr/bin/python3": "/opt/python3.6/bin/python3.6",
        "/opt/python3.6/bin/python3": "/opt/python3.6/bin/python3.6",
        "/opt/python3.6/bin/pip3": "/opt/python3.6/bin/pip3.6",
        "/opt/python3.6/bin/easy_install3": "/opt/python3.6/bin/easy_install-3.6",
    },
    tags = ["manual"],
    tars = ["//third_party/python:debian8_tar"],
)

container_test(
    name = "toolchain-test",
    configs = [
        "//container/common:go.yaml",
        "//container/common:java.yaml",
        "//container/common:python2.yaml",
        "//container/common:rbe-base.yaml",
        "//container/common/clang:clang.yaml",
        "//container/debian8:debian8.yaml",
        "//container/debian8/builders/rbe-debian8:rbe-debian8.yaml",
    ],
    image = ":toolchain",
    verbose = True,
)
