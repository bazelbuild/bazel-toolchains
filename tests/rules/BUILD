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
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "file_test",
    "rule_test",
)
load("//rules:gcs_push.bzl", "gcs_push")

filegroup(
    name = "this_file",
    srcs = ["BUILD"],
)

gcs_push(
    name = "gcs_push_with_no_target_name",
    bucket = "gs://xingao-test/test/",
    file = ":this_file",
)

rule_test(
    name = "test_gcs_push_rule_with_no_target_name",
    generates = [
        "gcs_push_with_no_target_name",
    ],
    rule = "gcs_push_with_no_target_name",
)

file_test(
    name = "test_gcs_push_with_no_target_name_output",
    file = ":gcs_push_with_no_target_name",
    regexp = "gsutil cp tests/rules/BUILD gs://xingao-test/test/BUILD",
)

gcs_push(
    name = "gcs_push_with_target_name",
    bucket = "gs://xingao-test/test/",
    file = ":this_file",
    target_file_name = "my_file",
)

rule_test(
    name = "test_gcs_push_with_target_name",
    generates = [
        "gcs_push_with_target_name",
    ],
    rule = "gcs_push_with_target_name",
)

file_test(
    name = "test_gcs_push_with_target_name_output",
    file = ":gcs_push_with_target_name",
    regexp = "gsutil cp tests/rules/BUILD gs://xingao-test/test/my_file",
)

gcs_push(
    name = "gcs_push_with_current_date",
    append_current_date = True,
    bucket = "gs://xingao-test/test/",
    file = ":this_file",
)

rule_test(
    name = "test_gcs_push_with_current_date",
    generates = [
        "gcs_push_with_current_date",
    ],
    rule = "gcs_push_with_current_date",
)

file_test(
    name = "test_gcs_push_with_current_date_output",
    file = ":gcs_push_with_current_date",
    regexp = "gsutil cp tests/rules/BUILD gs://xingao-test/test/BUILD_[$][(]date [+][%]Y[%]m[%]d[)]",
)
