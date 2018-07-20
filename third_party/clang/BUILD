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

# This BUILD file is used for installing clang.tar.gz into /usr/local
# of debian8-clang-fully-loaded container. The clang.tar.gz file was
# downloaded by gsutil_cp rule in the WORKSPACE file, and contains
# the same compiled clang binary as in
# https://console.cloud.google.com/launcher/details/google/clang-debian8

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "debian8_tar",
    package_dir = "/usr/local/",
    strip_prefix = ".",
    tags = ["manual"],
    deps = [
        "@debian8_clang_release//file",
    ],
)

pkg_tar(
    name = "debian9_tar",
    package_dir = "/usr/local/",
    strip_prefix = ".",
    tags = ["manual"],
    deps = [
        "@debian9_clang_release//file",
    ],
)

pkg_tar(
    name = "ubuntu16_04_tar",
    package_dir = "/usr/local/",
    strip_prefix = ".",
    tags = ["manual"],
    deps = [
        "@ubuntu16_04_clang_release//file",
    ],
)
