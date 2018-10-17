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

load("@base_images_docker//package_managers:download_pkgs.bzl", "download_pkgs")
load("@base_images_docker//package_managers:install_pkgs.bzl", "install_pkgs")
load("@base_images_docker//package_managers:apt_key.bzl", "add_apt_key")
load("//rules/container:docker_toolchains.bzl", "toolchain_container")

# This file contains some sample targets that excersise the container rules
# We just keep these as examples that should not break (unless indicated)
# with changes.

# The two targets below test that toolchain_container can sequentially
# install packages
toolchain_container(
    name = "rbe-test-xenial-base",
    base = "@official_xenial//image",
    packages = [
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

toolchain_container(
    name = "rbe-test-xenial-with-pkgs",
    additional_repos = [
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
    ],
    base = ":rbe-test-xenial-base.tar",
    keys = [
        "@bazel_gpg//file",
    ],
    packages = [
        "bazel",
    ],
)

# The target below (marked manual, should not be run by CI) shows a case of a
# package that cannot be installed because downloading it requires an additional
# package (apt-transport-https) not present in the base.
toolchain_container(
    name = "docker-noprereq-fails",
    additional_repos = [
        "deb [arch=amd64] https://download.docker.com/linux/debian jessie stable",
    ],
    base = "@debian8//image",
    keys = [
        "@debian_docker_gpg//file",
    ],
    packages = [
        "apt-transport-https",
        "docker-ce",
    ],
    tags = ["manual"],
)

# The targets below exemplify how to install a package whose download
# has pre-requisites in a way that the final container in which the
# package is installed does not need the pre-requisites
download_pkgs(
    name = "docker-prereq-packages",
    image_tar = "@debian8//image",
    packages = [
        "apt-transport-https",
    ],
)

install_pkgs(
    name = "docker-prereq-test",
    image_tar = "@debian8//image",
    installables_tar = ":docker-prereq-packages.tar",
    output_image_name = "docker-prereq-test:latest",
)

add_apt_key(
    name = "test-docker-with-keys",
    image = ":docker-prereq-test.tar",
    keys = [
        "@debian_docker_gpg//file",
    ],
)

download_pkgs(
    name = "test-docker-packages",
    additional_repos = [
        "deb [arch=amd64] https://download.docker.com/linux/debian jessie stable",
    ],
    image_tar = ":test-docker-with-keys.tar",
    packages = [
        "docker-ce",
    ],
)

install_pkgs(
    name = "docker",
    image_tar = "@debian8//image",
    installables_tar = ":test-docker-packages.tar",
    output_image_name = "docker:latest",
)
