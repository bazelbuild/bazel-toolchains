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

load(
    "//rules:package_names.bzl",
    "jessie_package_names",
    "trusty_package_names",
    "xenial_package_names",
)

http_archive(
    name = "io_bazel_rules_docker",
    urls = ["https://github.com/bazelbuild/rules_docker/archive/119bc3f0a7871d6f25f4d4a2705b9cb19756f9c4.tar.gz"],
    strip_prefix = "rules_docker-119bc3f0a7871d6f25f4d4a2705b9cb19756f9c4",
    sha256 = "6329b426670284c4be52969f3f0cf21431ad5012757b6e58c8e0e7014e6e6bdc",
)

load(
    "@io_bazel_rules_docker//container:container.bzl",
    container_repositories = "repositories",
    "container_pull",
)

container_repositories()

container_pull(
    name = "debian8-clang",
    digest = "sha256:6bf186b59972019e55acb6a46da721584ae5520218b0516542efdaa1f09caccf",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/clang-debian8",
)

container_pull(
    name = "official_trusty",
    registry = "index.docker.io",
    repository = "library/ubuntu",
    tag = "14.04",
)

container_pull(
    name = "official_xenial",
    registry = "index.docker.io",
    repository = "library/ubuntu",
    tag = "16.04",
)

http_archive(
    name = "distroless",
    urls = ["https://github.com/GoogleCloudPlatform/distroless/archive/42e71c20ccd63e2573c2cd5df03a12371480549f.tar.gz"],
    strip_prefix = "distroless-42e71c20ccd63e2573c2cd5df03a12371480549f",
    sha256 = "78289f23eb4bcc04b9329e12901a8675f64fda6abb1eda6317ebc6a5e8b229e2",
)

load(
    "@distroless//package_manager:package_manager.bzl",
    "package_manager_repositories",
    "dpkg_src",
    "dpkg_list",
)

package_manager_repositories()

dpkg_src(
    name = "bazel_apt",
    packages_gz_url = "http://storage.googleapis.com/bazel-apt/dists/stable/jdk1.8/binary-amd64/Packages.gz",
    package_prefix = "http://storage.googleapis.com/bazel-apt/",
    sha256 = "0fc4c6988ebf24705cfab0050cb5ad58e5b2aeb0e8cfb8921898a1809042416c",
)

dpkg_src(
    name = "debian_jessie",
    arch = "amd64",
    distro = "jessie",
    sha256 = "142cceae78a1343e66a0d27f1b142c406243d7940f626972c2c39ef71499ce61",
    snapshot = "20170821T035341Z",
    url = "http://snapshot.debian.org/archive",
)

dpkg_src(
    name = "debian_jessie_backports",
    arch = "amd64",
    distro = "jessie-backports",
    sha256 = "eba769f0a0bcaffbb82a8b61d4a9c8a0a3299d5111a68daeaf7e50cc0f76e0ab",
    snapshot = "20170821T035341Z",
    url = "http://snapshot.debian.org/archive",
)

dpkg_src(
    name = "ubuntu_trusty",
    packages_gz_url = "http://archive.ubuntu.com/ubuntu/dists/trusty/main/binary-amd64/Packages.gz",
    package_prefix = "http://archive.ubuntu.com/ubuntu/",
    sha256 = "59fa3195fd15bb2860fad4ff9ed37b249035e05ee327bed18f95dc88a0a41eb9",
)

dpkg_src(
    name = "ubuntu_trusty_backports",
    packages_gz_url = "http://archive.ubuntu.com/ubuntu/dists/trusty-backports/main/binary-amd64/Packages.gz",
    package_prefix = "http://archive.ubuntu.com/ubuntu/",
    sha256 = "6c395e01200a68752387ce86c9bdddad9e119a29c4351b069aff3d76dab3514e",
)

dpkg_src(
    name = "ubuntu_xenial",
    packages_gz_url = "http://archive.ubuntu.com/ubuntu/dists/xenial/main/binary-amd64/by-hash/SHA256/8d6ab57abf517d7712e4e4d23d762485af49f8140a83b221ea7282f82a51c795",
    package_prefix = "http://archive.ubuntu.com/ubuntu/",
    sha256 = "8d6ab57abf517d7712e4e4d23d762485af49f8140a83b221ea7282f82a51c795",
)

dpkg_src(
    name = "ubuntu_xenial_backports",
    packages_gz_url = "http://archive.ubuntu.com/ubuntu/dists/xenial-backports/main/binary-amd64/by-hash/SHA256/7d2b09c92824087485cb660822e5895b5d225b9fad1c20a7dbb41d6efa0fbfa5",
    package_prefix = "http://archive.ubuntu.com/ubuntu/",
    sha256 = "7d2b09c92824087485cb660822e5895b5d225b9fad1c20a7dbb41d6efa0fbfa5",
)

dpkg_src(
    name = "ubuntu_trusty_java",
    packages_gz_url = "http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/dists/trusty/main/binary-amd64/Packages.gz",
    package_prefix = "http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/",
    sha256 = "59337826f066721b5d5247e88ef22a0970e0e5dd5a3919fe4f5629777cf68c15",
)

dpkg_src(
    name = "ubuntu_xenial_java",
    packages_gz_url = "http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/dists/xenial/main/binary-amd64/Packages.gz",
    package_prefix = "http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/",
    sha256 = "3d1898fdfa48fda1d8982759bd6765090fefc2153d5f52108004bffb117d2a42",
)

dpkg_list(
    name = "bazel_package_bundle",
    packages = [
        "bazel",
    ],
    sources = [
        "@bazel_apt//file:Packages.json",
    ],
)

dpkg_list(
    name = "jessie_package_bundle",
    packages = jessie_package_names(),
    sources = [
        "@debian_jessie//file:Packages.json",
        "@debian_jessie_backports//file:Packages.json",
    ],
)

dpkg_list(
    name = "trusty_package_bundle",
    packages = trusty_package_names(),
    sources = [
        "@ubuntu_trusty//file:Packages.json",
        "@ubuntu_trusty_backports//file:Packages.json",
        "@ubuntu_trusty_java//file:Packages.json",
    ],
)

dpkg_list(
    name = "xenial_package_bundle",
    packages = xenial_package_names(),
    sources = [
        "@ubuntu_xenial//file:Packages.json",
        "@ubuntu_xenial_backports//file:Packages.json",
        "@ubuntu_xenial_java//file:Packages.json",
    ],
)
