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
    "//container/rules:debian_pkg_tar.bzl",
    "aggregate_debian_pkgs",
)

aggregate_debian_pkgs(
    name = "ubuntu16-04-debian_pkgs",
    base = "@ubuntu16_04//image",
    language_layers = [
        "//container/ubuntu16_04/builders/rbe-ubuntu16_04:base-ltl",
        "//container/ubuntu16_04/layers/clang:clang-ltl",
        "//container/ubuntu16_04/layers/go:go-ltl",
        "//container/ubuntu16_04/layers/java:java-ltl",
        "//container/ubuntu16_04/layers/java:java10-ltl",
        "//container/ubuntu16_04/layers/python:python-ltl",
    ],
)
