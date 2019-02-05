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
workspace(name = "bazel_toolchains")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(
    "//repositories:repositories.bzl",
    bazel_toolchains_repositories = "repositories",
)

bazel_toolchains_repositories()

load(
    "@io_bazel_rules_docker//toolchains/docker:toolchain.bzl",
    docker_toolchain_configure = "toolchain_configure",
)

docker_toolchain_configure(
    name = "docker_config",
    docker_path = "/usr/bin/docker",
)

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
    "//repositories:images.bzl",
    bazel_toolchains_images = "images",
)

bazel_toolchains_images()

load("@io_bazel_rules_go//go:def.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

container_pull(
    name = "official_jessie",
    registry = "index.docker.io",
    repository = "library/debian",
    tag = "jessie",
)

container_pull(
    name = "official_xenial",
    registry = "index.docker.io",
    repository = "library/ubuntu",
    tag = "16.04",
)

# Pinned to gcr.io/cloud-marketplace/google/clang-debian8@sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f
# solely for testing purpose used by //tests/config:debian8_clang_autoconfig_test.
container_pull(
    name = "debian8-clang-test",
    digest = "sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f",
    registry = "marketplace.gcr.io",
    repository = "google/clang-debian8",
)

# Test purpose only. bazel-toolchains repo at release for Bazel 0.10.0.
# https://github.com/bazelbuild/bazel-toolchains/releases/tag/acffd62
http_file(
    name = "bazel_toolchains_test",
    downloaded_file_path = "44200e0c026d86c53470d107b3697a3e46469c43.tar.gz",
    sha256 = "699b55a6916c687f4b7dc092dbbf5f64672cde0dc965f79717735ec4e5416556",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/44200e0c026d86c53470d107b3697a3e46469c43.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/44200e0c026d86c53470d107b3697a3e46469c43.tar.gz",
    ],
)

# Download test file to test gcs_file rule
load("//rules:gcs.bzl", "gcs_file")

gcs_file(
    name = "download_test_gcs_file",
    bucket = "gs://bazel-toolchains-test",
    downloaded_file_path = "test.txt",
    file = "test.txt",
    sha256 = "5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9",
)

load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig")

rbe_autoconfig(name = "rbe_default")

rbe_autoconfig(
    name = "rbe_default_no_checked_in_confs",
    use_checked_in_confs = False,
)

rbe_autoconfig(
    name = "rbe_default_with_output_base",
    config_dir = "default",
    output_base = "configs/ubuntu16_04_clang/1.1",
)

load("//rules:environments.bzl", "clang_env")
load("@bazel_skylib//lib:dicts.bzl", "dicts")

rbe_autoconfig(
    name = "rbe_msan_with_output_base",
    config_dir = "msan",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    output_base = "configs/ubuntu16_04_clang/1.1",
)

# Use in the RBE Ubuntu1604 container release.
rbe_autoconfig(
    name = "rbe_ubuntu1604_test",
    registry = "gcr.io",
    repository = "asci-toolchain/test-rbe-ubuntu16_04",
    tag = "latest",
)
