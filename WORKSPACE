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

# Use http_archive rule instead of git_repository rule
# https://docs.bazel.build/versions/master/be/workspace.html#git_repository
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "3af41275396fba9fcbb88741d946ac37e51c48888cbdaba2a58a2e75a492da91",
    strip_prefix = "rules_docker-4d8ec6570a5313fb0128e2354f2bc4323685282a",
    urls = ["https://github.com/bazelbuild/rules_docker/archive/4d8ec6570a5313fb0128e2354f2bc4323685282a.tar.gz"],
)

load(
    "@io_bazel_rules_docker//container:container.bzl",
    container_repositories = "repositories",
    "container_pull",
)

container_repositories()

container_pull(
    name = "debian8",
    digest = "sha256:412ef4d53215ff4a95d275ad48fe5196cb51f4f96b99c05058054b3bdf9443c1",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/debian8",
)

container_pull(
    name = "debian9",
    digest = "sha256:1b77b1d6cbc79af00b68050880b7d8cb24b7631fe366501bd55bf3986c744f03",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/debian9",
)

container_pull(
    name = "ubuntu16_04",
    digest = "sha256:c81e8f6bcbab8818fdbe2df6d367990ab55d85b4dab300931a53ba5d082f4296",
    registry = "gcr.io",
    repository = "cloud-marketplace/google/ubuntu16_04",
)

container_pull(
    name = "debian8-clang",
    digest = "sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf",
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

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")

go_rules_dependencies()

go_register_toolchains()

http_archive(
    name = "debian_docker",
    sha256 = "d17612c25ee9e5985641beb2a1cb56f9d4332d69b22ca27f3c95a456b5e4ab6c",
    strip_prefix = "base-images-docker-6360d9a3f781a0fa2cd7f7a91d3dcd7941b74026",
    urls = ["https://github.com/GoogleCloudPlatform/base-images-docker/archive/6360d9a3f781a0fa2cd7f7a91d3dcd7941b74026.tar.gz"],
)

http_file(
    name = "bazel_gpg",
    sha256 = "e0e806160454a3e5e308188439525896bf9881f1f2f0b887192428f517da4131",
    url = "https://bazel.build/bazel-release.pub.gpg",
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
    "package_manager_repositories",
    "dpkg_src",
    "dpkg_list",
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

# Golang
http_file(
    name = "golang_release",
    sha256 = "b5a64335f1490277b585832d1f6c7f8c6c11206cba5cd3f771dcb87b98ad1a33",
    urls = ["https://storage.googleapis.com/golang/go1.10.linux-amd64.tar.gz"],
)

load(
    "//third_party/clang:revision.bzl",
    "CLANG_REVISION",
)

# Clang
http_file(
    name = "debian8_clang_release",
    sha256 = "588ddbd83c32e7ab87fad58038c3712f6d1b0056f12ea746169ac7ecd33c93bf",
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-debian8/clang_" + CLANG_REVISION + ".tar.gz"],
)

http_file(
    name = "debian9_clang_release",
    sha256 = "434bbe2195845e42eb36ad2b88f6aec658d192614d47f71e15b861e09f71b4bd",
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-debian9/clang_" + CLANG_REVISION + ".tar.gz"],
)

http_file(
    name = "ubuntu16_04_clang_release",
    sha256 = "48bfc470810d483ffb2e826ed3540efc1da45fa89f416f8efa439242495e6239",
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-ubuntu16_04/clang_" + CLANG_REVISION + ".tar.gz"],
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
