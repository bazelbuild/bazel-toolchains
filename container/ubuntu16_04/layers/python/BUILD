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

PYTHON_CLEANUP_COMMANDS = (
    "find /usr/lib/python* -name __pycache__ -exec rm -rf {} +"
)

language_tool_layer(
    name = "python-ltl",
    base = "@ubuntu16_04//image",
    env = {
        "PATH": "$PATH:/opt/python3.6/bin",
    },
    installation_cleanup_commands = PYTHON_CLEANUP_COMMANDS,
    packages = [
        "python-dev",
        "python-setuptools",
        "python3-dev",
    ],
    symlinks = {
        "/usr/bin/python": "/usr/bin/python2.7",
        "/usr/bin/python3": "/opt/python3.6/bin/python3.6",
        "/opt/python3.6/bin/python3": "/opt/python3.6/bin/python3.6",
        "/opt/python3.6/bin/pip3": "/opt/python3.6/bin/pip3.6",
        "/opt/python3.6/bin/easy_install3": "/opt/python3.6/bin/easy_install-3.6",
    },
    tars = ["//third_party/python:ubuntu16_04_tar"],
)
