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

load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "file_test",
)
load("//rules/container:packages_metadata.bzl", "packages_metadata")
load("//rules/container:metadata_merge.bzl", "metadata_merge")

# Simply ensures the file supposed to be downloaded by the gce_file
# test rule was actually downloaded and the contents of the file was
# "0"
file_test(
    name = "gcs_file_test",
    content = "0",
    file = "@download_test_gcs_file//file:test.txt",
)

packages_metadata(
    name = "packages_metadata",
    metadata_csv = "packages_metadata.csv",
)

file_test(
    name = "test_packages_metadata",
    content = """packages:
- name: aaa
  version: "1"
- name: bbb
  version: "3"
- name: ccc
  version: "2"
""",
    file = ":packages_metadata.yaml",
)

metadata_merge(
    name = "metadata_merge",
    yamls = [
        "metadata_merge_file1.yaml",
        "metadata_merge_file2.yaml",
        "metadata_merge_file3.yaml",
        "metadata_merge_file4.yaml",
    ],
)

file_test(
    name = "test_metadata_merge",
    content = """tags:
- foo
- bar
packages:
- name: foo
  version: "1"
- name: bar
  version: "2"
""",
    file = ":metadata_merge.yaml",
)
