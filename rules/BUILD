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

exports_files([
    "install_bazel_head.sh",
    "install_bazel_version.sh",
    "docker_config.sh.tpl",
])

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

load("@bazel_skylib//:skylark_library.bzl", "skylark_library")

pkg_tar(
    name = "cc-sample-project-tar",
    srcs = [
        "cc-sample-project/BUILD.sample",
        "cc-sample-project/test.cc",
    ],
)

skylark_library(
    name = "environments",
    srcs = [
        "environments.bzl",
    ],
)

skylark_library(
    name = "toolchain_containers",
    srcs = [
        "toolchain_containers.bzl",
    ],
)

skylark_library(
    name = "gcs",
    srcs = [
        "gcs.bzl",
    ],
)

skylark_library(
    name = "docker_config",
    srcs = [
        "docker_config.bzl",
    ],
    deps = [
        "@io_bazel_rules_docker//container:container",
        "@bazel_toolchains//rules/container:docker_toolchains",
    ],
)
