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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "//skylib:package_names.bzl",
    "jessie_package_names",
)

# Use http_archive rule instead of git_repository rule
# https://docs.bazel.build/versions/master/be/workspace.html#git_repository
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "0c2a63f09e7e85e08d83a32af41fc93a3b4796c80fc3fe4626df82a63b92bcff",
    strip_prefix = "rules_docker-1144f83122750fe4aca139bd0f205d99c9bd94c1",
    urls = ["https://github.com/bazelbuild/rules_docker/archive/1144f83122750fe4aca139bd0f205d99c9bd94c1.tar.gz"],
)

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
    container_repositories = "repositories",
)

container_repositories()

container_pull(
    name = "debian8",
    digest = "sha256:943025384b0efebacf5473490333658dd190182e406e956ee4af65208d104332",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/debian8",
)

container_pull(
    name = "debian9",
    digest = "sha256:6b3aa04751aa2ac3b0c7be4ee71148b66d693ad212ce6d3244bd2a2a147f314a",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/debian9",
)

container_pull(
    name = "ubuntu16_04",
    digest = "sha256:c5f4c61e72b1f872e16b64577f8abb041a237f28f0513d4d482fc06d2532bb81",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/ubuntu16_04",
)

container_pull(
    name = "debian8-clang",
    digest = "sha256:8bb65bf0a0da8be48bbac07ebe743805f3dc5259203e19517098162bd23a768f",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/clang-debian8",
)

container_pull(
    name = "ubuntu16_04-clang",
    digest = "sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/clang-ubuntu",
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

# io_bazel_rules_go is the dependency of container_test rules.
http_archive(
    name = "io_bazel_rules_go",
    sha256 = "4b14d8dd31c6dbaf3ff871adcd03f28c3274e42abc855cb8fb4d01233c0154dc",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.10.1/rules_go-0.10.1.tar.gz",
)

load("@io_bazel_rules_go//go:def.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

http_archive(
    name = "base_images_docker",
    sha256 = "3d09c6f34671ee56c5cd39d215aaf639917ee487ec09e57643b1d6d55bc77bf6",
    strip_prefix = "base-images-docker-1782ac3d587c748805e9964f250a1d32a6033642",
    urls = ["https://github.com/GoogleCloudPlatform/base-images-docker/archive/1782ac3d587c748805e9964f250a1d32a6033642.tar.gz"],
)

http_file(
    name = "bazel_gpg",
    sha256 = "30af2ca7abfb65987cd61802ca6e352aadc6129dfb5bfc9c81f16617bc3a4416",
    url = "https://bazel.build/bazel-release.pub.gpg",
)

http_file(
    name = "debian_docker_gpg",
    sha256 = "1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570",
    url = "https://download.docker.com/linux/debian/gpg",
)

http_file(
    name = "xenial_docker_gpg",
    sha256 = "1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570",
    url = "https://download.docker.com/linux/ubuntu/gpg",
)

# Use http_archive rule instead of git_repository rule
# https://docs.bazel.build/versions/master/be/workspace.html#git_repository
http_archive(
    name = "distroless",
    sha256 = "44c5d3370df6983ef53cfc2347447c6595fea2d1951a1645660baf67657b8e23",
    strip_prefix = "distroless-94b5126dbe06c2cb4dc74f7c9bfe6394b8e6e44c",
    urls = ["https://github.com/GoogleCloudPlatform/distroless/archive/94b5126dbe06c2cb4dc74f7c9bfe6394b8e6e44c.tar.gz"],
)

load(
    "@distroless//package_manager:package_manager.bzl",
    "dpkg_list",
    "dpkg_src",
    "package_manager_repositories",
)

package_manager_repositories()

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
