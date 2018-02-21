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
load("@bazel_toolchains//rules:docker_config.bzl", "docker_toolchain_autoconfig")
load("@bazel_toolchains//rules:environments.bzl", "clang_env")

DEBIAN8_CLANG_DEFAULT_PACKAGES = [
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
]

DEBIAN8_CLANG_DEFAULT_REPOS = [
    "deb http://deb.debian.org/debian jessie-backports main",
    "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
]

DEBIAN8_CLANG_DEFAULT_KEYS = [
    "@bazel_gpg//file",
]

pkg_tar(
    name = "cc-sample-project-tar",
    srcs = [
        "cc-sample-project/BUILD.sample",
        "cc-sample-project/test.cc",
    ],
)

# Created on 2017.10.18
docker_toolchain_autoconfig(
    name = "debian8-clang-0.2.0-bazel_0.7.0-autoconfig",
    additional_repos = DEBIAN8_CLANG_DEFAULT_REPOS,
    base = "@debian8-clang//image",
    bazel_version = "0.7.0",
    env = clang_env(),
    keys = DEBIAN8_CLANG_DEFAULT_KEYS,
    packages = DEBIAN8_CLANG_DEFAULT_PACKAGES,
    tags = ["manual"],
    test = False,
)

# Created on 2017.11.28
docker_toolchain_autoconfig(
    name = "debian8-clang-0.2.0-bazel_0.8.0-autoconfig",
    additional_repos = DEBIAN8_CLANG_DEFAULT_REPOS,
    base = "@debian8-clang//image",
    bazel_version = "0.8.0",
    env = clang_env(),
    keys = DEBIAN8_CLANG_DEFAULT_KEYS,
    packages = DEBIAN8_CLANG_DEFAULT_PACKAGES,
    tags = ["manual"],
    test = False,
)

# Created on 2018.01.10
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:62ad7c44890792fdb2c2593fc24cfab7132e3a112d55bd453e09387906ae5e2f
docker_toolchain_autoconfig(
    name = "debian8-clang-0.2.0-bazel_0.9.0-autoconfig",
    additional_repos = DEBIAN8_CLANG_DEFAULT_REPOS,
    base = "@debian8-clang//image",
    bazel_version = "0.9.0",
    env = clang_env(),
    keys = DEBIAN8_CLANG_DEFAULT_KEYS,
    packages = DEBIAN8_CLANG_DEFAULT_PACKAGES,
    tags = ["manual"],
    test = True,
)

# Created on 2018.02.05
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:e57978199c9eb156bd7f63773387f3a238adf61acd71c4942ad91da50b4f241f
docker_toolchain_autoconfig(
    name = "debian8-clang-0.2.0-bazel_0.10.0-autoconfig",
    additional_repos = DEBIAN8_CLANG_DEFAULT_REPOS,
    base = "@debian8-clang//image",
    bazel_version = "0.10.0",
    env = clang_env(),
    keys = DEBIAN8_CLANG_DEFAULT_KEYS,
    packages = DEBIAN8_CLANG_DEFAULT_PACKAGES,
    tags = ["manual"],
    test = False,
)

# Created on 2018.02.13
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f
docker_toolchain_autoconfig(
    name = "debian8-clang-0.3.0-bazel_0.10.0-autoconfig",
    additional_repos = DEBIAN8_CLANG_DEFAULT_REPOS,
    base = "@debian8-clang//image",
    bazel_version = "0.10.0",
    env = clang_env(),
    keys = DEBIAN8_CLANG_DEFAULT_KEYS,
    packages = DEBIAN8_CLANG_DEFAULT_PACKAGES,
    tags = ["manual"],
    test = True,
)
