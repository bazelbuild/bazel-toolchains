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

# sh_tests below verify that the rbe_autoconfig targets have the
# right file structure in the external folder repo

sh_test(
    name = "rbe_autoconf_checked_in_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_checked_in//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_checked_in_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rbe_autoconf_checked_in//test:empty",
        "@rbe_autoconf_checked_in//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_checked_in_no_java_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_checked_in_no_java//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_checked_in_cc_confs",
        "assert_no_java_confs",
    ],
    data = [
        "@rbe_autoconf_checked_in_no_java//test:empty",
        "@rbe_autoconf_checked_in_no_java//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_checked_in_no_cc_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_checked_in_no_cc//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_no_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rbe_autoconf_checked_in_no_cc//test:empty",
        "@rbe_autoconf_checked_in_no_cc//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_generate_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_generate//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rbe_autoconf_generate//test:empty",
        "@rbe_autoconf_generate//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_generate_no_java_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_generate_no_java//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_cc_confs",
        "assert_no_java_confs",
    ],
    data = [
        "@rbe_autoconf_generate_no_java//test:empty",
        "@rbe_autoconf_generate_no_java//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_generate_no_cc_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_generate_no_cc//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_no_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rbe_autoconf_generate_no_cc//test:empty",
        "@rbe_autoconf_generate_no_cc//test:exported_testdata",
    ],
)

# file_test below check contents of produced BUILD files

file_test(
    name = "rbe_autoconf_checked_in_cc_alias_test",
    file = "@rbe_autoconf_checked_in//test:cc/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_checked_in_java_alias_test",
    file = "@rbe_autoconf_checked_in//test:java/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_checked_in_cc_alias_no_java_test",
    file = "@rbe_autoconf_checked_in_no_java//test:cc/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_checked_in_java_alias_no_cc_test",
    file = "@rbe_autoconf_checked_in_no_cc//test:java/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_generate_cc_toolchain_test",
    file = "@rbe_autoconf_generate//test:cc/test.BUILD",
    regexp = "cc_toolchain",
)

file_test(
    name = "rbe_autoconf_generate_cc_toolchain_config_test",
    file = "@rbe_autoconf_generate//test:cc/test.BUILD",
    regexp = "cc_toolchain_config",
)

file_test(
    name = "rbe_autoconf_generate_cc_compiler_test",
    file = "@rbe_autoconf_generate//test:cc/test.BUILD",
    regexp = "cc-compiler-k8",
)

file_test(
    name = "rbe_autoconf_generate_java_runtime_test",
    file = "@rbe_autoconf_generate//test:java/test.BUILD",
    regexp = "java_runtime",
)

# Tests that validate Bazel command executed in container
# includes the list of config repos
file_test(
    name = "rbe_autoconf_generate_run_in_container_test",
    file = "@rbe_autoconf_generate//test:container/run_in_container.sh",
    regexp = "bazel build @local_config_cc",
)

file_test(
    name = "rbe_autoconf_config_repos_run_in_container_test",
    file = "@rbe_autoconf_config_repos//test:container/run_in_container.sh",
    regexp = "@local_config_sh/",
)

file_test(
    name = "rbe_autoconf_config_repos_sh_toolchain_test",
    file = "@rbe_autoconf_config_repos//test:local_config_sh/test.BUILD",
    regexp = "sh_toolchain",
)

file_test(
    name = "rbe_autoconf_checked_in_platform_test",
    file = "@rbe_autoconf_checked_in//test:config/test.BUILD",
    regexp = "platform",
)

# Tests validate run_and_extract uses mount volumes (-v) vs
# data volumes.
file_test(
    name = "rbe_autoconf_generate_run_and_extract_test",
    file = "@rbe_autoconf_generate//test:run_and_extract.sh",
    regexp = "realpath",
)

file_test(
    name = "rbe_autoconf_copy_run_and_extract_test",
    file = "@rbe_autoconf_copy_resources//test:run_and_extract.sh",
    regexp = "data_volume",
)

# TODO(nlopezgi): Add tests that verify files were copied to output_folder
