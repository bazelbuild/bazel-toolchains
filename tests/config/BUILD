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

load("//rules/container:docker_toolchains.bzl", "toolchain_container")
load("//rules:docker_config.bzl", "docker_toolchain_autoconfig")
load(
    "//rules:environments.bzl",
    "clang_env",
    "debian8_clang_default_keys",
    "debian8_clang_default_packages",
    "debian8_clang_default_repos",
    "gcc_env",
)

bazel_latest_release = "0.19.0"

bazel_next_release = "0.19.2"

bazel_next_release_rc = "2"

# Use "rbe-test-" prefix for easy identification of images to remove after the tests.
toolchain_container(
    name = "rbe-test-jessie-with-pkgs",
    additional_repos = debian8_clang_default_repos(),
    base = "@official_jessie//image",
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages() + [
        "gcc",
    ],
)

# Targets here are for testing purposes, we do not actually
# maintain these configs anywhere
docker_toolchain_autoconfig(
    name = "debian-jessie-autoconfig",
    base = ":rbe-test-jessie-with-pkgs.tar",
    # TODO(nlopezgi): remove after bazel 0.19.2 is out
    bazel_version = bazel_latest_release,
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

docker_toolchain_autoconfig(
    name = "debian-jessie-bazel-head-autoconfig",
    base = ":rbe-test-jessie-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
    use_bazel_head = True,
)

docker_toolchain_autoconfig(
    name = "debian-jessie-custom-bazel-version-autoconfig",
    base = ":rbe-test-jessie-with-pkgs.tar",
    bazel_version = bazel_latest_release,
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Note that we only support Bazel rc versions at 0.10.0 or above.
docker_toolchain_autoconfig(
    name = "debian-jessie-custom-bazel-rc-version-autoconfig",
    base = ":rbe-test-jessie-with-pkgs.tar",
    bazel_rc_version = bazel_next_release_rc,
    bazel_version = bazel_next_release,
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Use "rbe-test-" prefix for easy identification of images to remove after the tests.
toolchain_container(
    name = "rbe-test-xenial-with-pkgs",
    additional_repos = [
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    base = "@official_xenial//image",
    keys = [
        "@bazel_gpg//file",
    ],
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
)

docker_toolchain_autoconfig(
    name = "ubuntu-xenial-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    # TODO(nlopezgi): remove after bazel 0.19.2 is out
    bazel_version = bazel_latest_release,
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

docker_toolchain_autoconfig(
    name = "external-repo-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    # TODO(nlopezgi): remove after bazel 0.19.2 is out
    bazel_version = bazel_latest_release,
    config_repos = [
        "local_config_sh",
        "local_config_cc",
    ],
    env = gcc_env(),
    git_repo = "https://github.com/bazelbuild/bazel",
    tags = ["manual"],
    test = True,
)

# To build this target run:
# bazel build //tests/config:this-project-repo-autoconfig --define mount_project=$(realpath .)
# To test it run:
# bazel test //tests/config:this-project-repo-autoconfig_test --define mount_project=$(realpath .)
docker_toolchain_autoconfig(
    name = "this-project-repo-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    bazel_version = bazel_latest_release,
    config_repos = [
        "local_config_sh",
        "local_config_cc",
    ],
    env = gcc_env(),
    incompatible_changes_off = True,
    mount_project = "$(mount_project)",
    tags = ["manual"],
    test = True,
)

docker_toolchain_autoconfig(
    name = "ubuntu-xenial-bazel-head-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
    use_bazel_head = True,
)

docker_toolchain_autoconfig(
    name = "ubuntu-xenial-custom-bazel-version-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    bazel_version = bazel_latest_release,
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Note that we only support Bazel rc versions at 0.10.0 or above.
docker_toolchain_autoconfig(
    name = "ubuntu-xenial-custom-bazel-rc-version-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    bazel_rc_version = bazel_next_release_rc,
    bazel_version = bazel_next_release,
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# For test purpose only. Used by //tests/config:debian8_clang_autoconfig_test.
# debian8_clang_autoconfig_test compares configs generated by this target and those
# already published in the repo to make sure the current docker_toolchain_autoconfig
# can generate the exact same configs as before.
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f
docker_toolchain_autoconfig(
    name = "debian8-clang-0.3.0-bazel_0.10.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang-test//image",
    bazel_version = "0.10.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

sh_test(
    name = "debian8_clang_autoconfig_test",
    size = "medium",
    timeout = "long",
    srcs = ["debian8_clang_autoconfig_test.sh"],
    data = [
        ":debian8-clang-0.3.0-bazel_0.10.0-autoconfig_outputs.tar",
        "@bazel_toolchains_test//file",
    ],
)
