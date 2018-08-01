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

load("//container/rules:docker_toolchains.bzl", "language_tool_layer")
load(
    "//container/ubuntu16_04/layers/gcloud:version.bzl",
    "GCLOUD_VERSION",
)

genrule(
    name = "generate_gcloud_yaml",
    srcs = ["gcloud.yaml.tpl"],
    outs = ["gcloud.yaml"],
    cmd = "sed 's|{_GCLOUD_VERSION}|" + GCLOUD_VERSION.rpartition("-")[0] + "|' <$< >$@",
)

language_tool_layer(
    name = "gcloud-ltl",
    additional_repos = [
        "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main",
    ],
    base = "@ubuntu16_04//image",
    keys = [
        "@gcloud_gpg//file",
    ],
    packages = [
        "google-cloud-sdk=%s" % GCLOUD_VERSION,
    ],
)
