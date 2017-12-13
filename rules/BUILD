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
load("@bazel_toolchains//rules:docker_config.bzl", "docker_toolchain_autoconfig")
load("@bazel_toolchains//rules:environments.bzl", "clang_env", "gcc_env")

pkg_tar(
    name = "cc-sample-project-tar",
    srcs = [
        "cc-sample-project/BUILD.sample",
        "cc-sample-project/test.cc",
    ],
)

docker_toolchain_autoconfig(
    name = "debian8-clang-0.7.0-autoconfig",
    base = "@debian8-clang//image",
    bazel_version = "0.7.0",
    env = clang_env(),
    packages = [
        "bazel",
        "ca-certificates-java=20161107'*'",
        "curl",
        "git",
        "openjdk-8-jdk-headless",
        "openjdk-8-jre-headless",
        "python-dev",
        "unzip",
        "wget",
        "zip",
    ],
    additional_repos = [
        "deb http://deb.debian.org/debian jessie-backports main",
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    keys = [
        "@bazel_gpg//file",
    ],
    tags = ["manual"],
)

docker_toolchain_autoconfig(
    name = "trusty-gcc-0.7.0-autoconfig",
    base = "@official_trusty//image",
    bazel_version = "0.7.0",
    env = gcc_env(),
    packages = [
        "bazel",
        "curl",
        "gcc",
        "git",
        "openjdk-8-jdk",
        "python-dev",
        "unzip",
        "wget",
        "zip",
    ],
    additional_repos = [
        "deb [arch=amd64] http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/ trusty main",
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    keys = [
        "@launchpad_openjdk_gpg//file",
        "@bazel_gpg//file",
    ],
    tags = ["manual"],
)

docker_toolchain_autoconfig(
    name = "xenial-gcc-0.7.0-autoconfig",
    base = "@official_xenial//image",
    bazel_version = "0.7.0",
    env = gcc_env(),
    packages = [
        "bazel",
        "curl",
        "gcc",
        "git",
        "openjdk-8-jdk",
        "python-dev",
        "unzip",
        "wget",
        "zip",
    ],
    additional_repos = [
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    keys = [
        "@bazel_gpg//file",
    ],
    tags = ["manual"],
)
