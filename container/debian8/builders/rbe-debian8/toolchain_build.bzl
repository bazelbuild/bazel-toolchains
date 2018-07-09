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

load(
    "//container/rules:docker_toolchains.bzl",
    "toolchain_container",
)
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

def toolchain_build(name, installables_tar = None):
    toolchain_container(
        name = name,
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
        installables_tar = installables_tar,
        language_layers = [
            "@bazel_toolchains//container/debian8/builders/rbe-debian8:base-ltl",
            "@bazel_toolchains//container/debian8/layers/clang:clang-ltl",
            "@bazel_toolchains//container/debian8/layers/go:go-ltl",
            "@bazel_toolchains//container/debian8/layers/java:java-ltl",
            "@bazel_toolchains//container/debian8/layers/python:python-ltl",
        ],
    )

    container_test(
        name = name + "-test",
        configs = [
            "@bazel_toolchains//container/debian8/builders/rbe-debian8:rbe-debian8.yaml",
            "@bazel_toolchains//container/common:clang.yaml",
            "@bazel_toolchains//container/common:go.yaml",
            "@bazel_toolchains//container/common:java.yaml",
            "@bazel_toolchains//container/common:python2.yaml",
            "@bazel_toolchains//container/common:rbe-base.yaml",
            "@bazel_toolchains//container/debian8:debian8.yaml",
        ],
        image = name,
        verbose = True,
    )
