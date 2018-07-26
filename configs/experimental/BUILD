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

load("@bazel_toolchains//rules:docker_config.bzl", "docker_toolchain_autoconfig")
load(
    "@bazel_toolchains//rules:environments.bzl",
    "clang_env",
    "debian8_clang_default_keys",
    "debian8_clang_default_packages",
    "debian8_clang_default_repos",
)

# Created on 2018.02.13
# Container: marketplace.gcr.io/google/clang-debian8@sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f
# This config is still experimental
# TODO(ngiraldo): remove experimental comment once this has been tested
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.11.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.11.0",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)
