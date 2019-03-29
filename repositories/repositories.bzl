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
        http_archive(
            name = "io_bazel_rules_go",
            urls = ["https://github.com/bazelbuild/rules_go/releases/download/0.16.5/rules_go-0.16.5.tar.gz"],
            sha256 = "7be7dc01f1e0afdba6c8eb2b43d2fa01c743be1b9273ab1eaf6c233df078d705",
        )

    if "base_images_docker" not in excludes:
        http_archive(
            name = "base_images_docker",
            sha256 = "ce6043d38aa7fad421910311aecec865beb060eb56d8c3eb5af62b2805e9379c",
            strip_prefix = "base-images-docker-7657d04ad9e30b9b8d981b96ae57634cd45ba18a",
            urls = ["https://github.com/GoogleContainerTools/base-images-docker/archive/7657d04ad9e30b9b8d981b96ae57634cd45ba18a.tar.gz"],
        )

    # =============================== Repo rule deps ==========================
    if "bazel_skylib" not in excludes:
        http_archive(
            name = "bazel_skylib",
            sha256 = "eb5c57e4c12e68c0c20bc774bfbc60a568e800d025557bc4ea022c6479acc867",
            strip_prefix = "bazel-skylib-0.6.0",
            urls = ["https://github.com/bazelbuild/bazel-skylib/archive/0.6.0.tar.gz"],
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
