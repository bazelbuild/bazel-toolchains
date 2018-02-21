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
    sha256 = "bc2182a51e19bf1fe5c3c33636b3e2827fac7be34af07690f9d612ca9bf31c3b",
    strip_prefix = "rules_docker-4d49182a85c745065e621c145238c5e9420ed91b",
    urls = ["https://github.com/bazelbuild/rules_docker/archive/4d49182a85c745065e621c145238c5e9420ed91b.tar.gz"],
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
    name = "debian8-clang",
    digest = "sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f",
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
    sha256 = "4d8d6244320dd751590f9100cf39fd7a4b75cd901e1f3ffdfd6f048328883695",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.9.0/rules_go-0.9.0.tar.gz",
)

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")

go_rules_dependencies()

go_register_toolchains()

http_archive(
    name = "debian_docker",
    sha256 = "15068de8576474c1852f48f8bedc547247d121266eae537b033d9864669b1294",
    strip_prefix = "base-images-docker-9a938f030b6eb1068ed9842bc43e2ceb601fb753",
    urls = ["https://github.com/GoogleCloudPlatform/base-images-docker/archive/9a938f030b6eb1068ed9842bc43e2ceb601fb753.tar.gz"],
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
    sha256 = "5401f820fddcc65fae34b5dc025ed522731aa55d89507078e63da85f420a0d63",
    strip_prefix = "distroless-886114394dfed219001ec3b068b139a3456e49d4",
    urls = ["https://github.com/GoogleCloudPlatform/distroless/archive/886114394dfed219001ec3b068b139a3456e49d4.tar.gz"],
)

load(
    "@distroless//package_manager:package_manager.bzl",
    "package_manager_repositories",
    "dpkg_src",
    "dpkg_list",
)

package_manager_repositories()

dpkg_src(
    name = "debian_jessie",
    arch = "amd64",
    distro = "jessie",
    sha256 = "20720c9367e9454dee3d173e4d3fd85ab5530292f4ec6654feb5a810b6bb37ce",
    snapshot = "20180130T043019Z",
    url = "http://snapshot.debian.org/archive",
)

dpkg_src(
    name = "debian_jessie_backports",
    arch = "amd64",
    distro = "jessie-backports",
    sha256 = "5858e520b7d7fe99bf2bd42864b5084bf86db9044b6fe4bdd98771d1ec7cc2f9",
    snapshot = "20180130T043019Z",
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
    sha256 = "15b0937615809f87321a457bb1265f946f9f6e736c563d6c5e0bd2c22e44f779",
    urls = ["https://storage.googleapis.com/golang/go1.9.4.linux-amd64.tar.gz"],
)

# Clang
http_file(
    name = "clang_release",
    sha256 = "2b002d1c6ede1d7627899e97a5da8a3fb81dd7cd3043b3594e4de67397b22d85",
    urls = ["https://storage.googleapis.com/clang-builds-stable/clang-debian8/clang_r322167.tar.gz"],
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
