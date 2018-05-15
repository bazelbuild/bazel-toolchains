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

JAVA_CLEANUP_COMMANDS = (
    "rm -rf " +
    "/etc/ssl/certs/java/cacerts " +
    "/tmp/hsperfdata_root/* " +
    "/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/classes.jsa"
)

PYTHON_CLEANUP_COMMANDS = (
    "find /usr/lib/python* -name __pycache__ -exec rm -rf {} +"
)

toolchain_container(
    name = "toolchain",
    base = "@ubuntu16_04//image",
    env = {
        # PATH envvar is a special case, and currently only the one in the
        # topmost layer is set. So that we override it here to include all.
        "PATH": "$PATH:/opt/python3.6/bin:/usr/local/go/bin",
    },
    language_layers = [
        "base-ltl",
        "clang-ltl",
        "go-ltl",
        "java-ltl",
        "python-ltl",
    ],
)

language_tool_layer(
    name = "base-ltl",
    base = "@ubuntu16_04//image",
    packages = [
        "binutils",
        "ca-certificates",
        "curl",
        "ed",
        "file",
        "git",
        "openssh-client",
        "unzip",
        "wget",
        "zip",
    ],
)

language_tool_layer(
    name = "clang-ltl",
    base = "@ubuntu16_04//image",
    env = {
        "CC": "/usr/local/bin/clang",
        "ASAN_SYMBOLIZER_PATH": "/usr/local/bin/llvm-symbolizer",
        "MSAN_SYMBOLIZER_PATH": "/usr/local/bin/llvm-symbolizer",
    },
    packages = [
        "libstdc++-4.9-dev",
    ],
    tars = [
        "//third_party/clang:ubuntu16_04_tar",
        "//third_party/libcxx:ubuntu16_04_tar",
    ],
)

language_tool_layer(
    name = "go-ltl",
    base = "@ubuntu16_04//image",
    env = {
        "GOPATH": "/go",
        "PATH": "$PATH:/usr/local/go/bin",
    },
    tars = ["//third_party/golang:tar"],
)

language_tool_layer(
    name = "java-ltl",
    base = "@ubuntu16_04//image",
    env = {
        "JAVA_HOME": "/usr/lib/jvm/java-8-openjdk-amd64",
    },
    installation_cleanup_commands = JAVA_CLEANUP_COMMANDS,
    packages = [
        "ca-certificates-java",
        "openjdk-8-jdk-headless",
        "openjdk-8-jre-headless",
    ],
    symlinks = {
        "/usr/bin/java": "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java",
    },
)

language_tool_layer(
    name = "python-ltl",
    base = "@ubuntu16_04//image",
    env = {
        "PATH": "$PATH:/opt/python3.6/bin",
    },
    installation_cleanup_commands = PYTHON_CLEANUP_COMMANDS,
    packages = [
        "python-dev",
        "python-numpy",
        "python-setuptools",
        "python3-dev",
    ],
    symlinks = {
        "/usr/bin/python": "/usr/bin/python2.7",
        "/usr/bin/python3": "/opt/python3.6/bin/python3.6",
        "/opt/python3.6/bin/python3": "/opt/python3.6/bin/python3.6",
        "/opt/python3.6/bin/pip3": "/opt/python3.6/bin/pip3.6",
        "/opt/python3.6/bin/easy_install3": "/opt/python3.6/bin/easy_install-3.6",
    },
    tars = ["//third_party/python:ubuntu16_04_tar"],
)

container_test(
    name = "toolchain-test",
    configs = [
        "//container/test:rbe-ubuntu16_04.yaml",
    ],
    image = ":toolchain",
)
