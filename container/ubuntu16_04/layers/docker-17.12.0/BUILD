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

load("//container/rules:docker_toolchains.bzl", "language_tool_layer", "toolchain_container")
load("@base_images_docker//package_managers:apt_key.bzl", "add_apt_key")
load("@base_images_docker//package_managers:download_pkgs.bzl", "download_pkgs")

exports_files(["docker-17.12.0.yaml"])

# Downloading "docker-ce" requires "apt-transport-https" to be installed
# in the container. So create a prerequisite container first.
toolchain_container(
    name = "docker-prereq",
    base = "@ubuntu16_04//image",
    packages = [
        "apt-transport-https",
    ],
)

add_apt_key(
    name = "docker-key-image",
    image = ":docker-prereq.tar",
    keys = [
        "@xenial_docker_gpg//file",
    ],
)

download_pkgs(
    name = "docker-packages",
    additional_repos = [
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable edge",
    ],
    image_tar = ":docker-key-image.tar",
    packages = [
        "apt-transport-https",
        "ca-certificates",
        "curl",
        "docker-ce=17.12.0~ce-0~ubuntu",
        "linux-image-extra-virtual",
    ],
)

language_tool_layer(
    name = "docker-ltl",
    base = "@ubuntu16_04//image",
    installables_tar = ":docker-packages.tar",
)
