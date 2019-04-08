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

file_test(
    name = "rbe_default_no_checked_in_confs_cc_wrapper_test",
    file = "@rbe_default_no_checked_in_confs//cc:cc_wrapper.sh",
    regexp = "/usr/local/bin/clang",
)

file_test(
    name = "rbe_default_no_checked_in_confs_cc_toolchain_config_test",
    file = "@rbe_default_no_checked_in_confs//cc:cc_toolchain_config.bzl",
    regexp = "/usr/local/bin/clang",
)

# Shell tests that run find inside a given rbe_autoconfig repo and check the
# found files match the expectation


