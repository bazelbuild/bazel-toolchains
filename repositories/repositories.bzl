# Copyright 2016 The Bazel Authors. All rights reserved.
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

# Once recursive workspace is implemented in Bazel, this file should cease
# to exist.
"""
Provides functions to pull all dependencies of this repository.
"""

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

def repositories():
    """Download dependencies of bazel-toolchains."""
    excludes = native.existing_rules().keys()

    if "bazel_skylib" not in excludes:
        http_archive(
            name = "bazel_skylib",
            sha256 = "e3fea03ff75a9821e84199466799ba560dbaebb299c655b5307f4df1e5970696",
            strip_prefix = "bazel-skylib-1.7.1",
            urls = ["https://github.com/bazelbuild/bazel-skylib/archive/1.7.1.tar.gz"],
        )
