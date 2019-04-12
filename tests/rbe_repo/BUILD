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
load(
    "//configs/ubuntu16_04_clang:versions.bzl",
    RBE_UBUNTU16_04_LATEST = "LATEST",
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
        "assert_java_home",
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
        "assert_no_java_home",
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
        # output and run_and_extract should not be present
        # as no config_repos were requested
        "assert_checked_in_confs",
        "assert_no_cc_confs",
        "assert_java_confs",
        "assert_java_home",
    ],
    data = [
        "@rbe_autoconf_generate_no_cc//test:empty",
        "@rbe_autoconf_generate_no_cc//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_custom_java_home_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_custom_java_home//test:empty)",
        "assert_basic_cofig",
        "assert_java_confs",
        "assert_no_java_home",
    ],
    data = [
        "@rbe_autoconf_custom_java_home//test:empty",
        "@rbe_autoconf_custom_java_home//test:exported_testdata",
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
    name = "rbe_autoconf_config_repos_no_cc_config_run_in_container_test",
    file = "@rbe_autoconf_config_repos_no_cc_config//test:container/run_in_container.sh",
    regexp = "bazel build @local_config_sh/",
)

file_test(
    name = "rbe_autoconf_config_repos_no_cc_config_sh_toolchain_test",
    file = "@rbe_autoconf_config_repos_no_cc_config//test:local_config_sh/test.BUILD",
    regexp = "sh_toolchain",
)

# Tests for platform target
file_test(
    name = "rbe_autoconf_checked_in_platform_test",
    file = "@rbe_autoconf_checked_in//test:config/test.BUILD",
    regexp = "platform",
)

file_test(
    name = "rbe_autoconf_checked_in_platform_containersha_test",
    file = "@rbe_autoconf_checked_in//test:config/test.BUILD",
    regexp = RBE_UBUNTU16_04_LATEST,
)

file_test(
    name = "rbe_autoconf_generate_platform_test",
    file = "@rbe_autoconf_generate//test:config/test.BUILD",
    regexp = "platform",
)

file_test(
    name = "rbe_autoconf_checked_generate_containersha_test",
    file = "@rbe_autoconf_generate//test:config/test.BUILD",
    regexp = RBE_UBUNTU16_04_LATEST,
)

file_test(
    name = "rbe_autoconf_old_container_platform_test",
    file = "@rbe_autoconf_old_container//test:config/test.BUILD",
    regexp = "platform",
)

file_test(
    name = "rbe_autoconf_old_container_containersha_test",
    file = "@rbe_autoconf_old_container//test:config/test.BUILD",
    regexp = "87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c",
)

file_test(
    name = "rbe_autoconf_custom_container_platform_test",
    file = "@rbe_autoconf_custom_container//test:config/test.BUILD",
    regexp = "platform",
)

file_test(
    name = "rbe_autoconf_custom_containersha_test",
    file = "@rbe_autoconf_custom_container//test:config/test.BUILD",
    regexp = "cda3a8608d0fc545dffc6c68f6cfab8eda280c7a1558bde0753ed2e8e3006224",
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

# Tests for use of java_home attr
file_test(
    name = "rbe_autoconf_custom_java_home_java_runtime_test",
    file = "@rbe_autoconf_custom_java_home//test:java/test.BUILD",
    regexp = "java_runtime",
)

file_test(
    name = "rbe_autoconf_custom_java_home_java_runtime_value_test",
    file = "@rbe_autoconf_custom_java_home//test:java/test.BUILD",
    regexp = "test-case-java-home",
)

# Tests that verify rbe_autoconfig with custom env variables.
# These tests verify that the env variables passed are present
# in the resulting C/C++ config.
# If any of the tests below fail after a new Bazel config is released
# (tests are pineed to the _ubuntu1604_bazel version),
# its possible that C/C++ config rules have changed and the tests
# need to be updated accordingly.
file_test(
    name = "rbe_autoconf_custom_env_abi_libc_version_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_toolchain_config.bzl",
    regexp = "abi_libc_version = \"test_abi_libc_version_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_abi_version_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_toolchain_config.bzl",
    regexp = "abi_version = \"test_abi_version_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_bazel_host_system_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_toolchain_config.bzl",
    regexp = "host_system_name = \"test_bazel_host_system_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_bazel_target_cpu_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_toolchain_config.bzl",
    regexp = "target_cpu = \"test_bazel_target_cpu_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_bazel_target_libc_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_toolchain_config.bzl",
    regexp = "target_libc = \"test_bazel_target_libc_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_bazel_target_system_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_toolchain_config.bzl",
    regexp = "target_system_name = \"test_bazel_target_system_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_clang_toolchain_config_bzl_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_toolchain_config.bzl",
    regexp = "path= \"/usr/local/bin/clang++\"",
)

file_test(
    name = "rbe_autoconf_custom_env_clang_toolchain_config_bzl_2_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_toolchain_config.bzl",
    regexp = "compiler = \"clang++\"",
)

file_test(
    name = "rbe_autoconf_custom_env_clang_cc_wrapper_sh_test",
    file = "@rbe_autoconf_custom_env//test:cc/cc_wrapper.sh",
    regexp = "/usr/local/bin/clang++",
)

file_test(
    name = "rbe_autoconf_custom_env_clang_build_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "compiler = \"clang++\"",
)

file_test(
    name = "rbe_autoconf_custom_env_clang_build_2_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "\"k8|clang++\": \":cc-compiler-k8\"",
)

# TODO(nlopezgi): Add tests that verify files were copied to output_folder
