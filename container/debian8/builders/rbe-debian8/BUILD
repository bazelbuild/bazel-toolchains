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
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

language_tool_layer(
    name = "base-ltl",
    base = "@debian8//image",
    packages = [
        "binutils",
        "ca-certificates",
        "curl",
        "ed",
        "file",
        "git",
        "less",
        "netcat",
        "openssh-client",
        "patch",
        "unzip",
        "wget",
        "zip",
    ],
)

toolchain_container(
    name = "toolchain",
    base = "@debian8//image",
    cmd = [
        "/bin/sh",
        "-c",
        "/bin/bash",
    ],
    env = {
        # PATH envvar is a special case, and currently only the one in the
        # topmost layer is set. So that we override it here to include all.
        "PATH": "$PATH:/opt/python3.6/bin:/usr/local/go/bin",
        "LANG": "C.UTF-8",
        "LANGUAGE": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
    },
    language_layers = [
        "base-ltl",
        "//container/debian8/layers/clang:clang-ltl",
        "//container/debian8/layers/go:go-ltl",
        "//container/debian8/layers/java:java-ltl",
        "//container/debian8/layers/python:python-ltl",
    ],
)

container_test(
    name = "toolchain-test",
    configs = [
        ":rbe-debian8.yaml",
        "//container/common:clang.yaml",
        "//container/common:go.yaml",
        "//container/common:java.yaml",
        "//container/common:python2.yaml",
        "//container/common:rbe-base.yaml",
        "//container/debian8:debian8.yaml",
    ],
    image = ":toolchain",
    verbose = True,
)
