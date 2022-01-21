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

# Use pre-generated toolchain configs for the latest Bazel and latest Ubuntu 16.04
# container. Pre-generated configs are only provided as a convenience for
# experimenting with configuring Bazel for remote builds. Further, there are
# no guarantees on how long after a new release of Bazel or the Ubuntu 16.04
# container mentioned above the corresponding pre-generated configs will be
# available. So, never depend directly on the URL mentioned below to download
# toolchain configs in production because they may break without warning.
# For more information and alternatives, please visit:
# https://github.com/bazelbuild/bazel-toolchains#rbe_configs_gen---cli-tool-to-generate-configs
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rbe_default",
    # The sha256 digest of the tarball might change without notice. So it's not
    # included here. Please refer to the link mentioned above for instructions
    # on how to generate your own configs.
    urls = ["https://storage.googleapis.com/rbe-toolchain/bazel-configs/rbe-ubuntu1604/latest/rbe_default.tar"],
)

load(
    "//repositories:repositories.bzl",
    bazel_toolchains_repositories = "repositories",
)

bazel_toolchains_repositories()
