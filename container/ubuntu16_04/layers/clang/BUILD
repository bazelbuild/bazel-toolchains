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

load(
    "//container/rules:docker_toolchains.bzl",
    "language_tool_layer",
)

language_tool_layer(
    name = "clang-ltl",
    base = "@ubuntu16_04//image",
    env = {
        "CC": "/usr/local/bin/clang",
        "ASAN_SYMBOLIZER_PATH": "/usr/local/bin/llvm-symbolizer",
        "MSAN_SYMBOLIZER_PATH": "/usr/local/bin/llvm-symbolizer",
    },
    packages = [
        "libstdc++-4.9-dev",
    ],
    tars = [
        "//third_party/clang:ubuntu16_04_tar",
        "//third_party/libcxx:ubuntu16_04_tar",
    ],
)
