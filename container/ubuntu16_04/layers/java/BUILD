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
    "@bazel_toolchains//rules/container:docker_toolchains.bzl",
    "language_tool_layer",
)

JAVA_CLEANUP_COMMANDS = (
    "rm -rf " +
    "/etc/ssl/certs/java/cacerts " +
    "/tmp/hsperfdata_root/* " +
    "/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/classes.jsa"
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
    name = "java10-ltl",
    base = "@ubuntu16_04//image",
    tars = [
        "//third_party/openjdk:open_jdk_tar",
        "//third_party/openjdk:open_jdk_src_tar",
    ],
)
