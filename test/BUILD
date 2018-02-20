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

load("@bazel_toolchains//rules:docker_config.bzl", "container_install_pkgs", "docker_toolchain_autoconfig")
load("@bazel_toolchains//rules:environments.bzl", "clang_env", "gcc_env")

container_install_pkgs(
    name = "jessie-with-pkgs",
    base = "@official_jessie//image",
    packages = [
        "bazel",
        "ca-certificates-java=20161107'*'",
        "curl",
        "gcc",
        "git",
        "openjdk-8-jdk-headless",
        "openjdk-8-jre-headless",
        "python-dev",
        "unzip",
        "wget",
        "zip",
    ],
    additional_repos = [
        "deb http://deb.debian.org/debian jessie-backports main",
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    keys = [
        "@bazel_gpg//file",
    ],
)

# Targets here are for testing purposes, we do not actually
# maintain these configs anywhere
docker_toolchain_autoconfig(
    name = "debian-jessie-autoconfig",
    base = ":jessie-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

docker_toolchain_autoconfig(
    name = "debian-jessie-bazel-head-autoconfig",
    base = ":jessie-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    use_bazel_head = True,
    test = True,
)

docker_toolchain_autoconfig(
    name = "debian-jessie-custom-bazel-version-autoconfig",
    base = ":jessie-with-pkgs.tar",
    bazel_version = "0.9.0",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Note that we only support Bazel rc versions at 0.10.0 or above.
docker_toolchain_autoconfig(
    name = "debian-jessie-custom-bazel-rc-version-autoconfig",
    base = ":jessie-with-pkgs.tar",
    bazel_version = "0.11.0",
    bazel_rc_version = "1",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

container_install_pkgs(
    name = "trusty-with-pkgs",
    base = "@official_trusty//image",
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
        "deb [arch=amd64] http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/ trusty main",
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    keys = [
        "@launchpad_openjdk_gpg//file",
        "@bazel_gpg//file",
    ],
)

docker_toolchain_autoconfig(
    name = "ubuntu-trusty-autoconfig",
    base = ":trusty-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

docker_toolchain_autoconfig(
    name = "ubuntu-trusty-bazel-head-autoconfig",
    base = ":trusty-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    use_bazel_head = True,
    test = True,
)

docker_toolchain_autoconfig(
    name = "ubuntu-trusty-custom-bazel-version-autoconfig",
    base = ":trusty-with-pkgs.tar",
    bazel_version = "0.9.0",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Note that we only support Bazel rc versions at 0.10.0 or above.
docker_toolchain_autoconfig(
    name = "ubuntu-trusty-custom-bazel-rc-version-autoconfig",
    base = ":trusty-with-pkgs.tar",
    bazel_version = "0.11.0",
    bazel_rc_version = "1",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

container_install_pkgs(
    name = "xenial-with-pkgs",
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
    base = ":xenial-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

docker_toolchain_autoconfig(
    name = "ubuntu-xenial-bazel-head-autoconfig",
    base = ":xenial-with-pkgs.tar",
    env = gcc_env(),
    tags = ["manual"],
    use_bazel_head = True,
    test = True,
)

docker_toolchain_autoconfig(
    name = "ubuntu-xenial-custom-bazel-version-autoconfig",
    base = ":xenial-with-pkgs.tar",
    bazel_version = "0.9.0",
    env = gcc_env(),
    tags = ["manual"],
    test = True,
)

# Note that we only support Bazel rc versions at 0.10.0 or above.
docker_toolchain_autoconfig(
    name = "ubuntu-xenial-custom-bazel-rc-version-autoconfig",
    base = ":xenial-with-pkgs.tar",
    bazel_version = "0.11.0",
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
      "//rules:debian8-clang-0.3.0-bazel_0.10.0-autoconfig",
      "@bazel_toolchains_test//file",
    ],
)
