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
    "//skylib:package_names.bzl",
    "jessie_package_names",
    "trusty_package_names",
    "xenial_package_names",
)

# Use http_archive rule instead of git_repository rule
# https://docs.bazel.build/versions/master/be/workspace.html#git_repository
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "6329b426670284c4be52969f3f0cf21431ad5012757b6e58c8e0e7014e6e6bdc",
    strip_prefix = "rules_docker-119bc3f0a7871d6f25f4d4a2705b9cb19756f9c4",
    urls = ["https://github.com/bazelbuild/rules_docker/archive/119bc3f0a7871d6f25f4d4a2705b9cb19756f9c4.tar.gz"],
)

load(
    "@io_bazel_rules_docker//container:container.bzl",
    container_repositories = "repositories",
    "container_pull",
)

container_repositories()

container_pull(
    name = "debian8",
    digest = "sha256:527a326166d399fd2eb12df3fe1186a925ad98ea27857a67914536bfcae0e084",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/debian8",
)

container_pull(
    name = "debian8-clang",
    digest = "sha256:e57978199c9eb156bd7f63773387f3a238adf61acd71c4942ad91da50b4f241f",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/clang-debian8",
)

container_pull(
    name = "official_jessie",
    registry = "index.docker.io",
    repository = "library/debian",
    tag = "jessie",
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
    name = "debian_docker",
    sha256 = "11692d97f7de2680028e6744f68637e7be0544df081840f1a4bb99f53735aeef",
    strip_prefix = "base-images-docker-087fe18d18a7ae1b1a8c6dcad932b5190ad3567e",
    urls = ["https://github.com/GoogleCloudPlatform/base-images-docker/archive/087fe18d18a7ae1b1a8c6dcad932b5190ad3567e.tar.gz"],
)

http_file(
    name = "bazel_gpg",
    sha256 = "e0e806160454a3e5e308188439525896bf9881f1f2f0b887192428f517da4131",
    url = "https://bazel.build/bazel-release.pub.gpg",
)

http_file(
    name = "launchpad_openjdk_gpg",
    sha256 = "54b6274820df34a936ccc6f5cb725a9b7bb46075db7faf0ef7e2d86452fa09fd",
    url = "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0xEB9B1D8886F44E2A",
)

# Use http_archive rule instead of git_repository rule
# https://docs.bazel.build/versions/master/be/workspace.html#git_repository
http_archive(
    name = "distroless",
    sha256 = "78289f23eb4bcc04b9329e12901a8675f64fda6abb1eda6317ebc6a5e8b229e2",
    strip_prefix = "distroless-42e71c20ccd63e2573c2cd5df03a12371480549f",
    urls = ["https://github.com/GoogleCloudPlatform/distroless/archive/42e71c20ccd63e2573c2cd5df03a12371480549f.tar.gz"],
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
    package_prefix = "http://storage.googleapis.com/bazel-apt/",
    packages_gz_url = "http://storage.googleapis.com/bazel-apt/dists/stable/jdk1.8/binary-amd64/Packages.gz",
    sha256 = "c76f1eed46b34cd894eae5d980bddf0ea80a969d5ff12333dd99fdadfc4858d8",
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
    name = "debian_jessie_ca_certs",
    arch = "amd64",
    distro = "jessie",
    sha256 = "26e8275be588d35313eac65a1a88b17a1052eb323255048b13bdf0653421a9f2",
    snapshot = "20161107T033615Z",
    url = "http://snapshot.debian.org/archive",
)

dpkg_src(
    name = "ubuntu_trusty",
    package_prefix = "http://archive.ubuntu.com/ubuntu/",
    packages_gz_url = "http://archive.ubuntu.com/ubuntu/dists/trusty/main/binary-amd64/Packages.gz",
    sha256 = "59fa3195fd15bb2860fad4ff9ed37b249035e05ee327bed18f95dc88a0a41eb9",
)

dpkg_src(
    name = "ubuntu_trusty_backports",
    package_prefix = "http://archive.ubuntu.com/ubuntu/",
    packages_gz_url = "http://archive.ubuntu.com/ubuntu/dists/trusty-backports/main/binary-amd64/Packages.gz",
    sha256 = "8219acccd8c95a002a02b7c16f63d3425eb3dd3958d0a685fa3ba7eb45e4c09c",
)

dpkg_src(
    name = "ubuntu_xenial",
    package_prefix = "http://archive.ubuntu.com/ubuntu/",
    packages_gz_url = "http://archive.ubuntu.com/ubuntu/dists/xenial/main/binary-amd64/by-hash/SHA256/8d6ab57abf517d7712e4e4d23d762485af49f8140a83b221ea7282f82a51c795",
    sha256 = "8d6ab57abf517d7712e4e4d23d762485af49f8140a83b221ea7282f82a51c795",
)

dpkg_src(
    name = "ubuntu_xenial_backports",
    package_prefix = "http://archive.ubuntu.com/ubuntu/",
    packages_gz_url = "http://archive.ubuntu.com/ubuntu/dists/xenial-backports/main/binary-amd64/by-hash/SHA256/db5c10f8771cc9e623109f1f71b2d78bc55c0909e76dadc341d241ba3abdef10",
    sha256 = "db5c10f8771cc9e623109f1f71b2d78bc55c0909e76dadc341d241ba3abdef10",
)

dpkg_src(
    name = "ubuntu_trusty_java",
    package_prefix = "http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/",
    packages_gz_url = "http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/dists/trusty/main/binary-amd64/Packages.gz",
    sha256 = "59337826f066721b5d5247e88ef22a0970e0e5dd5a3919fe4f5629777cf68c15",
)

dpkg_src(
    name = "ubuntu_xenial_java",
    package_prefix = "http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/",
    packages_gz_url = "http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/dists/xenial/main/binary-amd64/Packages.gz",
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
    name = "jessie_ca_certs_package_bundle",
    packages = ["ca-certificates-java"],
    sources = [
        "@debian_jessie_ca_certs//file:Packages.json",
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

# Golang
http_file(
    name = "golang_release",
    sha256 = "de874549d9a8d8d8062be05808509c09a88a248e77ec14eb77453530829ac02b",
    urls = ["https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz"],
)

# Clang
http_file(
    name = "clang_release",
    sha256 = "61699cafb7d8542f30b39eda9fc43b23f13ecbac1d349976374f7555659c2d2f",
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-debian8/clang_r319946.tar.gz"],
)

# Test purpose only. bazel-toolchains repo at release for Bazel 0.10.0.
# https://github.com/bazelbuild/bazel-toolchains/releases/tag/acffd62
http_file(
    name = "bazel_toolchains_test",
    urls = [
      "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/acffd62731b1545c32e1c34e72fd526598ab9a66.tar.gz",
      "https://github.com/bazelbuild/bazel-toolchains/archive/acffd62731b1545c32e1c34e72fd526598ab9a66.tar.gz",
    ],
    sha256 = "f820436a685db00945df1282df7688187b48aeed91c17686023712afcf453996",
)
