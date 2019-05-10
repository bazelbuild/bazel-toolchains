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
load("@bazel_toolchains//deps:io_bazel_rules_go.bzl", io_bazel_rules_go_version = "version")
load("@bazel_toolchains//deps:base_images_docker.bzl", base_images_docker_version = "version")

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

    # io_bazel_rules_go is the dependency of container_test rules.
    if "io_bazel_rules_go" not in excludes:
        git_repository(
            name = "io_bazel_rules_go",
            # TODO (suvanjan): Change this back to track releases instead of
            # HEAD once copybara supports tracking tagged commits.
            commit = io_bazel_rules_go_version,
            remote = "https://github.com/bazelbuild/rules_go.git",
            # TODO (suvanjan): Add sha256 field once copybara supports it.
        )

    if "base_images_docker" not in excludes:
        git_repository(
            name = "base_images_docker",
            commit = base_images_docker_version,
            remote = "https://github.com/GoogleContainerTools/base-images-docker.git",
            # TODO (suvanjan): Add sha256 field once copybara supports it.
        )

    # =============================== Repo rule deps ==========================
    if "bazel_skylib" not in excludes:
        http_archive(
            name = "bazel_skylib",
            sha256 = "2ea8a5ed2b448baf4a6855d3ce049c4c452a6470b1efd1504fdb7c1c134d220a",
            strip_prefix = "bazel-skylib-0.8.0",
            urls = ["https://github.com/bazelbuild/bazel-skylib/archive/0.8.0.tar.gz"],
        )

    # ================================ GPG Keys ================================
    # Bazel gpg key necessary to install Bazel in the containers.
    if "bazel_gpg" not in excludes:
        http_file(
            name = "bazel_gpg",
            downloaded_file_path = "bazel_gpg",
            sha256 = "30af2ca7abfb65987cd61802ca6e352aadc6129dfb5bfc9c81f16617bc3a4416",
            urls = ["https://bazel.build/bazel-release.pub.gpg"],
        )
