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

load("@base_images_docker//util:run.bzl", "container_run_and_extract")

container_run_and_extract(
    name = "debian8_tar",
    commands = [
        "tar cvf /python.tar --mtime='1970-01-01' /opt/python3.6",
    ],
    extract_file = "/python.tar",
    image = "@debian8_python3//image",
)

container_run_and_extract(
    name = "ubuntu16_04_tar",
    commands = [
        "tar cvf /python.tar --mtime='1970-01-01' /opt/python3.6",
    ],
    extract_file = "/python.tar",
    image = "@ubuntu16_04_python3//image",
)
