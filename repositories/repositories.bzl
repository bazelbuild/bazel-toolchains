# Copyright 2016 The Bazel Authors. All rights reserved.
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

# Once recursive workspace is implemented in Bazel, this file should cease
# to exist.
"""
Provides functions to pull all dependencies of this repository.
"""

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
    "http_file",
)
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_toolchains//deps:io_bazel_rules_docker.bzl", io_bazel_rules_docker_version = "version")

def repositories():
    """Download dependencies of bazel-toolchains."""
    excludes = native.existing_rules().keys()

    # ============================== Repositories ==============================
    if "io_bazel_rules_docker" not in excludes:
        git_repository(
            name = "io_bazel_rules_docker",
            commit = io_bazel_rules_docker_version,
            remote = "https://github.com/bazelbuild/rules_docker.git",
            # TODO (suvanjan): Add sha256 field once copybara supports it.
        )

        # Register the docker toolchain type
        native.register_toolchains(
            # Register the default docker toolchain that expects the 'docker'
            # executable to be in the PATH
            "@io_bazel_rules_docker//toolchains/docker:default_linux_toolchain",
            "@io_bazel_rules_docker//toolchains/docker:default_windows_toolchain",
            "@io_bazel_rules_docker//toolchains/docker:default_osx_toolchain",
        )

    # =============================== Repo rule deps ==========================
    if "bazel_skylib" not in excludes:
        http_archive(
            name = "bazel_skylib",
            sha256 = "e5d90f0ec952883d56747b7604e2a15ee36e288bb556c3d0ed33e818a4d971f2",
            strip_prefix = "bazel-skylib-1.0.2",
            urls = ["https://github.com/bazelbuild/bazel-skylib/archive/1.0.2.tar.gz"],
        )

    # ================================ GPG Keys ================================
    # Bazel gpg key necessary to install Bazel in the containers.
    if "bazel_gpg" not in excludes:
        http_file(
            name = "bazel_gpg",
            downloaded_file_path = "bazel_gpg",
            sha256 = "547ec71b61f94b07909969649d52ee069db9b0c55763d3add366ca7a30fb3f6d",
            urls = ["https://bazel.build/bazel-release.pub.gpg"],
        )
