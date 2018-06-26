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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def repositories():
    """Download dependencies of bazel-toolchains."""
    excludes = native.existing_rules().keys()

    if "io_bazel_rules_docker" not in excludes:
        http_archive(
            name = "io_bazel_rules_docker",
            sha256 = "88890f58983b683f12c04ed14611b34c9f0140d8bfbdc089594187dc5d4025a5",
            strip_prefix = "rules_docker-a901aa066469d6840d254d6f5618b90a8ec983dc",
            urls = ["https://github.com/bazelbuild/rules_docker/archive/a901aa066469d6840d254d6f5618b90a8ec983dc.tar.gz"],
        )

    # io_bazel_rules_go is the dependency of container_test rules.
    if "io_bazel_rules_go" not in excludes:
        http_archive(
            name = "io_bazel_rules_go",
            sha256 = "4b14d8dd31c6dbaf3ff871adcd03f28c3274e42abc855cb8fb4d01233c0154dc",
            urls = ["https://github.com/bazelbuild/rules_go/releases/download/0.10.1/rules_go-0.10.1.tar.gz"],
        )

    if "base_images_docker" not in excludes:
        http_archive(
            name = "base_images_docker",
            sha256 = "89f1855aab28f6ebfbfba0dee46fa211dd36577ce45e7f01aef64733656dc51e",
            strip_prefix = "base-images-docker-0d0080ed000d0ad00489d87e0016e05000a6937f",
            urls = ["https://github.com/GoogleCloudPlatform/base-images-docker/archive/0d0080ed000d0ad00489d87e0016e05000a6937f.tar.gz"],
        )

    if "distroless" not in excludes:
        http_archive(
            name = "distroless",
            sha256 = "44c5d3370df6983ef53cfc2347447c6595fea2d1951a1645660baf67657b8e23",
            strip_prefix = "distroless-94b5126dbe06c2cb4dc74f7c9bfe6394b8e6e44c",
            urls = ["https://github.com/GoogleCloudPlatform/distroless/archive/94b5126dbe06c2cb4dc74f7c9bfe6394b8e6e44c.tar.gz"],
        )

    # Bazel gpg key necessary to install Bazel in the containers.
    if "bazel_gpg" not in excludes:
        native.http_file(
            name = "bazel_gpg",
            sha256 = "30af2ca7abfb65987cd61802ca6e352aadc6129dfb5bfc9c81f16617bc3a4416",
            url = "https://bazel.build/bazel-release.pub.gpg",
        )
