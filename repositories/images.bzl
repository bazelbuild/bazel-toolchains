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

load("//rules:toolchain_containers.bzl", "toolchain_container_sha256s")
load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)

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
            "@io_bazel_rules_docker//container:container.bzl",
            "container_pull",
            container_repositories = "repositories",
        )

        container_repositories()

        load(
            "//repositories:repositories.bzl",
            bazel_toolchains_images = "images",
        )

        bazel_toolchains_images()

        ...

    """
    excludes = native.existing_rules().keys()

    if "debian8" not in excludes:
        # TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
        container_pull(
            name = "debian8",
            digest = toolchain_container_sha256s()["debian8"],
            registry = "l.gcr.io",
            repository = "google/debian8",
        )

    if "debian9" not in excludes:
        # TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
        container_pull(
            name = "debian9",
            digest = toolchain_container_sha256s()["debian9"],
            registry = "l.gcr.io",
            repository = "google/debian9",
        )

    if "ubuntu16_04" not in excludes:
        # TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
        container_pull(
            name = "ubuntu16_04",
            digest = toolchain_container_sha256s()["ubuntu16_04"],
            registry = "l.gcr.io",
            repository = "google/ubuntu16_04",
        )

    if "debian8_python3" not in excludes:
        # TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
        # Get debian8-built python3 interpreter from l.gcr.io/google/python:latest.
        # Base image: gcr.io/google-appengine/debian8:latest
        # Base image ref: https://github.com/GoogleCloudPlatform/python-runtime/blob/a8a3e8b2d3239c184843db818e34a06f12dc1190/build.sh#L155
        container_pull(
            name = "debian8_python3",
            digest = toolchain_container_sha256s()["debian8_python3"],
            registry = "l.gcr.io",
            repository = "google/python",
        )

    if "ubuntu16_04_python3" not in excludes:
        # Get ubuntu16_04-built python3 interpreter from gcr.io/google-appengine/python:latest.
        # Base image: gcr.io/gcp-runtimes/ubuntu_16_0_4:latest
        # Base image ref: https://github.com/GoogleCloudPlatform/python-runtime/blob/a8a3e8b2d3239c184843db818e34a06f12dc1190/build.sh#L153
        container_pull(
            name = "ubuntu16_04_python3",
            digest = toolchain_container_sha256s()["ubuntu16_04_python3"],
            registry = "gcr.io",
            repository = "google-appengine/python",
        )

    if "debian8-clang" not in excludes:
        # TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
        container_pull(
            name = "debian8-clang",
            digest = toolchain_container_sha256s()["debian8_clang"],
            registry = "l.gcr.io",
            repository = "google/clang-debian8",
        )

    if "ubuntu16_04-clang" not in excludes:
        # TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
        container_pull(
            name = "ubuntu16_04-clang",
            digest = toolchain_container_sha256s()["ubuntu16_04_clang"],
            registry = "l.gcr.io",
            repository = "google/clang-ubuntu",
        )

    # Note that we pull trusty base from "index.docker.io" registry and not from
    # "marketplace.gcr.io" as we do for other base images.
    if "trusty" not in excludes:
        container_pull(
            name = "trusty",
            registry = "index.docker.io",
            repository = "library/ubuntu",
            tag = "14.04",
        )
