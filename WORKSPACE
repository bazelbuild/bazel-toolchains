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
)
load(
    "//repositories:repositories.bzl",
    bazel_toolchains_repositories = "repositories",
)

bazel_toolchains_repositories()

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_go//go:def.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

load(
    "@distroless//package_manager:package_manager.bzl",
    "dpkg_list",
    "dpkg_src",
    "package_manager_repositories",
)

# This is only needed by the old package manager.
package_manager_repositories()

load("//rules:toolchain_containers.bzl", "toolchain_container_sha256s")

# TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
container_pull(
    name = "debian8",
    digest = toolchain_container_sha256s()["debian8"],
    registry = "l.gcr.io",
    repository = "google/debian8",
)

# TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
container_pull(
    name = "debian9",
    digest = toolchain_container_sha256s()["debian9"],
    registry = "l.gcr.io",
    repository = "google/debian9",
)

# TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
container_pull(
    name = "ubuntu16_04",
    digest = toolchain_container_sha256s()["ubuntu16_04"],
    registry = "l.gcr.io",
    repository = "google/ubuntu16_04",
)

# TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
# Get debian8-built python3 interpreter from l.gcr.io/google/python:latest.
# Base image: gcr.io/google-appengine/debian8:latest
# Base image ref: https://github.com/GoogleCloudPlatform/python-runtime/blob/a8a3e8b2d3239c184843db818e34a06f12dc1190/build.sh#L155
container_pull(
    name = "debian8_python3",
    digest = toolchain_container_sha256s()["debian8_python3"],
    registry = "l.gcr.io",
    repository = "google/python",
)

# Get ubuntu16_04-built python3 interpreter from gcr.io/google-appengine/python:latest.
# Base image: gcr.io/gcp-runtimes/ubuntu_16_0_4:latest
# Base image ref: https://github.com/GoogleCloudPlatform/python-runtime/blob/a8a3e8b2d3239c184843db818e34a06f12dc1190/build.sh#L153
container_pull(
    name = "ubuntu16_04_python3",
    digest = toolchain_container_sha256s()["ubuntu16_04_python3"],
    registry = "gcr.io",
    repository = "google-appengine/python",
)

# TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
# l.gcr.io/google/clang-debian8:r328903
container_pull(
    name = "debian8-clang",
    digest = toolchain_container_sha256s()["debian8_clang"],
    registry = "l.gcr.io",
    repository = "google/clang-debian8",
)

# TODO(xingao) Switch to use "marketplace.gcr.io" registry once Buildkite support proper auth.
# l.gcr.io/google/clang-ubuntu:r328903
container_pull(
    name = "ubuntu16_04-clang",
    digest = toolchain_container_sha256s()["ubuntu16_04_clang"],
    registry = "l.gcr.io",
    repository = "google/clang-ubuntu",
)

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

http_file(
    name = "debian_docker_gpg",
    sha256 = "1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570",
    urls = ["https://download.docker.com/linux/debian/gpg"],
)

http_file(
    name = "xenial_docker_gpg",
    sha256 = "1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570",
    urls = ["https://download.docker.com/linux/ubuntu/gpg"],
)

http_file(
    name = "gcloud_gpg",
    sha256 = "226ba1072f20e4ff97ee4f94e87bf45538a900a6d9b25399a7ac3dc5a2f3af87",
    urls = ["https://packages.cloud.google.com/apt/doc/apt-key.gpg"],
)

# The Debian snapshot datetime to use.
# This is kept up-to-date with https://github.com/GoogleCloudPlatform/base-images-docker/blob/master/WORKSPACE.
DEB_SNAPSHOT = "20180312T052343Z"

dpkg_src(
    name = "debian_jessie",
    arch = "amd64",
    distro = "jessie",
    sha256 = "20720c9367e9454dee3d173e4d3fd85ab5530292f4ec6654feb5a810b6bb37ce",
    snapshot = DEB_SNAPSHOT,
    url = "http://snapshot.debian.org/archive",
)

dpkg_src(
    name = "debian_jessie_backports",
    arch = "amd64",
    distro = "jessie-backports",
    sha256 = "28afadff87f53bcb754d571df4174f0b8cbabd1600be82a062932df6eb4b7b70",
    snapshot = DEB_SNAPSHOT,
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

load(
    "//third_party/golang:revision.bzl",
    "GOLANG_REVISION",
    "GOLANG_SHA256",
)

# Golang
http_file(
    name = "golang_release",
    sha256 = GOLANG_SHA256,
    urls = ["https://storage.googleapis.com/golang/go" + GOLANG_REVISION + ".linux-amd64.tar.gz"],
)

load(
    "//third_party/clang:revision.bzl",
    "CLANG_REVISION",
    "DEBIAN8_CLANG_SHA256",
    "DEBIAN9_CLANG_SHA256",
    "UBUNTU16_04_CLANG_SHA256",
)

# Clang
http_file(
    name = "debian8_clang_release",
    sha256 = DEBIAN8_CLANG_SHA256,
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-debian8/clang_" + CLANG_REVISION + ".tar.gz"],
)

http_file(
    name = "debian9_clang_release",
    sha256 = DEBIAN9_CLANG_SHA256,
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-debian9/clang_" + CLANG_REVISION + ".tar.gz"],
)

http_file(
    name = "ubuntu16_04_clang_release",
    sha256 = UBUNTU16_04_CLANG_SHA256,
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-ubuntu16_04/clang_" + CLANG_REVISION + ".tar.gz"],
)

load(
    "//third_party/libcxx:revision.bzl",
    "DEBIAN8_LIBCXX_SHA256",
    "DEBIAN9_LIBCXX_SHA256",
    "LIBCXX_REVISION",
    "UBUNTU16_04_LIBCXX_SHA256",
)

# libcxx
http_file(
    name = "debian8_libcxx_release",
    sha256 = DEBIAN8_LIBCXX_SHA256,
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-debian8/libcxx-msan_" + LIBCXX_REVISION + ".tar.gz"],
)

http_file(
    name = "debian9_libcxx_release",
    sha256 = DEBIAN9_LIBCXX_SHA256,
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-debian9/libcxx-msan_" + LIBCXX_REVISION + ".tar.gz"],
)

http_file(
    name = "ubuntu16_04_libcxx_release",
    sha256 = UBUNTU16_04_LIBCXX_SHA256,
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-ubuntu16_04/libcxx-msan_" + LIBCXX_REVISION + ".tar.gz"],
)

load(
    "//third_party/openjdk:revision.bzl",
    "JDK_VERSION",
    "OPENJDK_SHA256",
    "OPENJDK_SRC_SHA256",
)

# Axul JDK (from Bazel's OpenJDK Mirror)
http_file(
    name = "azul_open_jdk",
    sha256 = OPENJDK_SHA256,
    urls = ["https://mirror.bazel.build/openjdk/azul-zulu" + JDK_VERSION + "/zulu" + JDK_VERSION + "-linux_x64-allmodules.tar.gz"],
)

http_file(
    name = "azul_open_jdk_src",
    sha256 = OPENJDK_SRC_SHA256,
    urls = ["https://mirror.bazel.build/openjdk/azul-zulu" + JDK_VERSION + "/zsrc" + JDK_VERSION + ".zip"],
)

# Test purpose only. bazel-toolchains repo at release for Bazel 0.10.0.
# https://github.com/bazelbuild/bazel-toolchains/releases/tag/acffd62
http_file(
    name = "bazel_toolchains_test",
    sha256 = "699b55a6916c687f4b7dc092dbbf5f64672cde0dc965f79717735ec4e5416556",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/44200e0c026d86c53470d107b3697a3e46469c43.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/44200e0c026d86c53470d107b3697a3e46469c43.tar.gz",
    ],
)

load(
    "//container/ubuntu16_04/layers/bazel:version.bzl",
    "BAZEL_VERSION_SHA256S",
)

# Download the Bazel installer.sh for all supported versions.
[http_file(
    name = "bazel_%s_installer" % (bazel_version.replace(".", "")),
    sha256 = bazel_sha256,
    urls = [
        "https://releases.bazel.build/" + bazel_version + "/release/bazel-" + bazel_version + "-installer-linux-x86_64.sh",
        "https://github.com/bazelbuild/bazel/releases/download/" + bazel_version + "/bazel-" + bazel_version + "-installer-linux-x86_64.sh",
    ],
) for bazel_version, bazel_sha256 in BAZEL_VERSION_SHA256S.items()]
