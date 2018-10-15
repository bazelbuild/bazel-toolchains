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

load("//container/common/bazel:version.bzl", "BAZEL_VERSION_SHA256S")

exports_files(glob(["**"]))

# Generate Bazel container testing yaml files with all supported Bazel versions.
[genrule(
    name = "generate_bazel_%s_yaml" % bazel_version,
    srcs = [":bazel.yaml.tpl"],
    outs = ["bazel_%s.yaml" % bazel_version],
    cmd = "sed 's|{_BAZEL_VERSION}|" + bazel_version + "|' <$< >$@",
) for bazel_version, _ in BAZEL_VERSION_SHA256S.items()]
