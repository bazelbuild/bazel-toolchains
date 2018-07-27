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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

def repositories():
    """Download dependencies of bazel-toolchains."""
    excludes = native.existing_rules().keys()

    if "io_bazel_rules_docker" not in excludes:
        http_archive(
            name = "io_bazel_rules_docker",
            sha256 = "b4775b7c4fc76e3113dab643ee35eefbabca0b44908d0d1c85dcf29cab7c0638",
            strip_prefix = "rules_docker-c7a93454d27e09ef707dfca53887ed0ff4372f04",
            urls = ["https://github.com/bazelbuild/rules_docker/archive/c7a93454d27e09ef707dfca53887ed0ff4372f04.tar.gz"],
        )

    # io_bazel_rules_go is the dependency of container_test rules.
    if "io_bazel_rules_go" not in excludes:
        http_archive(
            name = "io_bazel_rules_go",
            sha256 = "ba79c532ac400cefd1859cbc8a9829346aa69e3b99482cd5a54432092cbc3933",
            urls = ["https://github.com/bazelbuild/rules_go/releases/download/0.13.0/rules_go-0.13.0.tar.gz"],
        )

    if "base_images_docker" not in excludes:
        http_archive(
            name = "base_images_docker",
            sha256 = "e2b1b7254270bb7605e814a9dbf6d1e4ae04a11136ff1714fbfdabe3f87f7cf9",
            strip_prefix = "base-images-docker-12801524f867e657fbb5d1a74f31618aff181ac6",
            urls = ["https://github.com/GoogleCloudPlatform/base-images-docker/archive/12801524f867e657fbb5d1a74f31618aff181ac6.tar.gz"],
        )

    if "distroless" not in excludes:
        http_archive(
            name = "distroless",
            sha256 = "daf9b18ca2d4ae11501846a311011ef2fa2c8db95529c5b5f6069977967712e0",
            strip_prefix = "distroless-10f0810b962145e4636282005226c4eb72519182",
            urls = ["https://github.com/GoogleCloudPlatform/distroless/archive/10f0810b962145e4636282005226c4eb72519182.tar.gz"],
        )

    # Bazel gpg key necessary to install Bazel in the containers.
    if "bazel_gpg" not in excludes:
        http_file(
            name = "bazel_gpg",
            sha256 = "30af2ca7abfb65987cd61802ca6e352aadc6129dfb5bfc9c81f16617bc3a4416",
            urls = ["https://bazel.build/bazel-release.pub.gpg"],
        )
