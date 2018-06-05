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

exports_files(glob(["**"]))

load("//container/rules:docker_toolchains.bzl", "toolchain_container")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

toolchain_container(
    name = "bazel-toolchain",
    additional_repos = [
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    base = "@debian8//image",
    keys = [
        "@bazel_gpg//file",
    ],
    language_layers = [
        "//container/rbe-debian8:java-ltl",
    ],
    packages = [
        "bazel",
    ],
)

container_test(
    name = "bazel-toolchain-test",
    configs = [
        "//container/test:bazel.yaml",
    ],
    image = ":bazel-toolchain",
)
