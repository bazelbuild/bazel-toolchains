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

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load(
    "@bazel_toolchains//rules:docker_config.bzl",
    "all_tools",
    "default_tools",
    "docker_toolchain_autoconfig",
)
load("@bazel_toolchains//rules:environments.bzl", "clang_env", "gcc_env")
load("@distroless//cacerts:cacerts.bzl", "cacerts")
load(
    "@jessie_package_bundle//file:packages.bzl",
    jessie_packages = "packages",
)
load(
    "@trusty_package_bundle//file:packages.bzl",
    trusty_packages = "packages",
)
load(
    "@xenial_package_bundle//file:packages.bzl",
    xenial_packages = "packages",
)

pkg_tar(
    name = "cc-sample-project-tar",
    srcs = [
        "cc-sample-project/BUILD.sample",
        "cc-sample-project/test.cc",
    ],
)

cacerts(
    name = "jessie_cacerts",
    deb = jessie_packages["ca-certificates"],
)

cacerts(
    name = "trusty_cacerts",
    deb = trusty_packages["ca-certificates"],
)

cacerts(
    name = "xenial_cacerts",
    deb = xenial_packages["ca-certificates"],
)

docker_toolchain_autoconfig(
    name = "debian8-clang-0.7.0-autoconfig",
    base = "@debian8-clang//image",
    bazel_version = "0.7.0",
    distro = "jessie",
    env = clang_env(),
    install_tools = default_tools,
    tags = ["manual"],
)

docker_toolchain_autoconfig(
    name = "trusty-gcc-0.7.0-autoconfig",
    base = "@official_trusty//image",
    bazel_version = "0.7.0",
    distro = "trusty",
    env = gcc_env(),
    install_tools = all_tools,
    tags = ["manual"],
)

docker_toolchain_autoconfig(
    name = "xenial-gcc-0.7.0-autoconfig",
    base = "@official_xenial//image",
    bazel_version = "0.7.0",
    distro = "xenial",
    env = gcc_env(),
    install_tools = all_tools,
    tags = ["manual"],
)
