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
Provides functions to pull the images used by this repository.
"""

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)
load("//rules:toolchain_containers.bzl", "toolchain_container_sha256s")

_REGISTRY = "marketplace.gcr.io"

def images():
    """Pull containers used in bazel-toolchains.

    container_pull() rule depends on

    load(
        "@io_bazel_rules_docker//container:container.bzl",
        "container_pull",
    )

    which then depends on:

    load(
        "//repositories:repositories.bzl",
        bazel_toolchains_repositories = "repositories",
    )

    bazel_toolchains_repositories()

    Therefore, in the WORKSPACE, the right order to load the dependencies is:

        load(
            "//repositories:repositories.bzl",
            bazel_toolchains_repositories = "repositories",
        )

        bazel_toolchains_repositories()

        load(
            "@io_bazel_rules_docker//repositories:repositories.bzl",
            container_repositories = "repositories",
        )

        container_repositories()

        load(
            "@io_bazel_rules_docker//container:container.bzl",
            "container_pull",
        )

        load(
            "//repositories:repositories.bzl",
            bazel_toolchains_images = "images",
        )

        bazel_toolchains_images()

        ...

    """
    excludes = native.existing_rules().keys()

    if "debian8-clang" not in excludes:
        container_pull(
            name = "debian8-clang",
            digest = toolchain_container_sha256s()["debian8_clang"],
            registry = _REGISTRY,
            repository = "google/clang-debian8",
        )

    if "ubuntu16_04-clang" not in excludes:
        container_pull(
            name = "ubuntu16_04-clang",
            digest = toolchain_container_sha256s()["ubuntu16_04_clang"],
            registry = _REGISTRY,
            repository = "google/clang-ubuntu",
        )
