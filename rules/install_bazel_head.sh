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

#!/usr/bin/env bash
# Checks out from github the bazel project and builds it using bazel
# Script requires git and bazel present in path
set -e
echo === Installing Bazel from head ===

mkdir -p /src/bazel
cd /src/bazel/
git clone https://github.com/bazelbuild/bazel.git
cd bazel
bazel build //src:bazel --spawn_strategy=standalone
cp /src/bazel/bazel/bazel-bin/src/bazel /usr/bin/bazel
rm -rf /src/bazel
