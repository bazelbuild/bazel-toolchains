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

load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

exports_files([
    "install_bazel_head.sh",
    "install_bazel_version.sh",
])

filegroup(
    name = "bazel_installers",
    srcs = [
        "build_bazel_version.sh",
        "install_bazel_head.sh",
        "install_bazel_version.sh",
    ],
)

pkg_tar(
    name = "cc-sample-project-tar",
    srcs = [
        "cc-sample-project/BUILD.sample",
        "cc-sample-project/test.cc",
    ],
)

bzl_library(
    name = "environments",
    srcs = [
        "environments.bzl",
    ],
)

bzl_library(
    name = "toolchain_containers",
    srcs = [
        "toolchain_containers.bzl",
    ],
)

bzl_library(
    name = "gcs",
    srcs = [
        "gcs.bzl",
    ],
)

bzl_library(
    name = "docker_config",
    srcs = [
        "docker_config.bzl",
    ],
    deps = [
        "@bazel_toolchains//rules/container:docker_toolchains",
        "@io_bazel_rules_docker//container",
    ],
)

bzl_library(
    name = "rbe_repo",
    srcs = [
        "rbe_repo.bzl",
    ],
    deps = [
        "@bazel_toolchains//rules/rbe_repo",
    ],
)
