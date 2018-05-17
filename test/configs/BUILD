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

load("//container/rules:docker_toolchains.bzl", "toolchain_container")
load("@bazel_toolchains//rules:docker_config.bzl", "docker_toolchain_autoconfig")
load("@bazel_toolchains//rules:environments.bzl",
    "gcc_env",
    "debian8_clang_default_keys",
    "debian8_clang_default_packages",
    "debian8_clang_default_repos"
)

# Use "rbe-test-" prefix for easy identification of images to remove after the tests.
toolchain_container(
    name = "rbe-test-jessie-with-pkgs",
    base = "@official_jessie//image",
    packages = debian8_clang_default_packages() + [
        "gcc",
    ],
    additional_repos = debian8_clang_default_repos(),
    keys = debian8_clang_default_keys(),
)

# Targets here are for testing purposes, we do not actually
# maintain these configs anywhere
docker_toolchain_autoconfig(
    name = "debian-jessie-autoconfig",
    base = ":rbe-test-jessie-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

docker_toolchain_autoconfig(
    name = "debian-jessie-bazel-head-autoconfig",
    base = ":rbe-test-jessie-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    use_bazel_head = True,
    test = True,
)

docker_toolchain_autoconfig(
    name = "debian-jessie-custom-bazel-version-autoconfig",
    base = ":rbe-test-jessie-with-pkgs.tar",
    bazel_version = "0.13.0",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Note that we only support Bazel rc versions at 0.10.0 or above.
docker_toolchain_autoconfig(
    name = "debian-jessie-custom-bazel-rc-version-autoconfig",
    base = ":rbe-test-jessie-with-pkgs.tar",
    bazel_version = "0.13.0",
    bazel_rc_version = "1",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Use "rbe-test-" prefix for easy identification of images to remove after the tests.
toolchain_container(
    name = "rbe-test-xenial-with-pkgs",
    base = "@official_xenial//image",
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
    additional_repos = [
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    keys = [
        "@bazel_gpg//file",
    ],
)

docker_toolchain_autoconfig(
    name = "ubuntu-xenial-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

docker_toolchain_autoconfig(
    name = "ubuntu-xenial-bazel-head-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    use_bazel_head = True,
    test = True,
)

docker_toolchain_autoconfig(
    name = "ubuntu-xenial-custom-bazel-version-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    bazel_version = "0.13.0",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Note that we only support Bazel rc versions at 0.10.0 or above.
docker_toolchain_autoconfig(
    name = "ubuntu-xenial-custom-bazel-rc-version-autoconfig",
    base = ":rbe-test-xenial-with-pkgs.tar",
    bazel_version = "0.13.0",
    bazel_rc_version = "1",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

sh_test(
    name = "debian8_clang_autoconfig_test",
    size = "medium",
    timeout = "long",
    srcs = ["debian8_clang_autoconfig_test.sh"],
    data = [
      "//configs/debian8_clang:debian8-clang-0.3.0-bazel_0.10.0-autoconfig",
      "@bazel_toolchains_test//file",
    ],
)
