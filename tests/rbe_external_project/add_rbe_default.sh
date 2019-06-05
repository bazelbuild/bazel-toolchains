#!/usr/bin/env bash
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

# Simple script to use bazel-toolchains srcs in the current client
# and add the rbe_default repo to WORKSPACE if it does not exist
# This script should be executed from the root of an external project's srcs

set -ex
mv WORKSPACE WORKSPACE.bak

if grep -q rbe_default "WORKSPACE.bak"; then
  sed '0,/load/{s/load/local_repository(\n    name = \"bazel_toolchains\",\n    path = \"..\/\",\n)\nload/}' WORKSPACE.bak > WORKSPACE
else
  sed '0,/load/{s/load/local_repository(\n    name = \"bazel_toolchains\",\n    path = \"..\/\",\n)\nload(\"@bazel_toolchains\/\/rules:rbe_repo.bzl\", \"rbe_autoconfig\")\nrbe_autoconfig(name = \"rbe_default\")\nload/}' WORKSPACE.bak > WORKSPACE
fi

if [ -f ".bazelrc" ]; then
    rm .bazelrc
fi
