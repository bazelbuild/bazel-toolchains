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
    RBE_CONTAINERS_MAP = "CONTAINER_TO_CONFIG_SPEC_NAMES",
    RBE_UBUNTU16_04_LATEST = "LATEST",
)
load(
    "//configs/dependency-tracking:ubuntu1604.bzl",
    _ubuntu1604_bazel = "bazel",
)
load(
    "//rules/rbe_repo:toolchain_config_suite_spec.bzl",
    "default_toolchain_config_suite_spec",
)
load(
    "//tests/rbe_repo:versions_test.bzl",
    test_toolchain_config_suite_autogen_spec = "TOOLCHAIN_CONFIG_AUTOGEN_SPEC",
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
        "assert_image_pulled",
        "assert_configs_tar",
    ],
    data = [
        "@rbe_autoconf_generate//test:empty",
        "@rbe_autoconf_generate//test:exported_testdata",
    ],
)

# TODO: Enable in CI
sh_test(
    name = "rbe_autoconf_generate_windows_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_generate_windows//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_cc_confs_windows",
        "assert_java_confs",
        "assert_image_pulled",
        "assert_configs_tar",
    ],
    data = [
        "@rbe_autoconf_generate_windows//test:empty",
        "@rbe_autoconf_generate_windows//test:exported_testdata",
    ],
    tags = ["windows"],
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
        "assert_configs_tar",
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
        "assert_configs_tar",
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
        "assert_checked_in_confs",
        "assert_java_confs",
        "assert_no_cc_confs",
        "assert_no_java_home",
    ],
    data = [
        "@rbe_autoconf_custom_java_home//test:empty",
        "@rbe_autoconf_custom_java_home//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_detect_java_home_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_detect_java_home//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_java_confs",
        "assert_no_cc_confs",
        "assert_java_home",
    ],
    data = [
        "@rbe_autoconf_detect_java_home//test:empty",
        "@rbe_autoconf_detect_java_home//test:exported_testdata",
    ],
)

# file_test below check contents of produced BUILD files

file_test(
    name = "rbe_autoconf_checked_in_cc_alias_test",
    file = "@rbe_autoconf_checked_in//test:cc/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_checked_in_java_runtime_test",
    file = "@rbe_autoconf_checked_in//test:java/test.BUILD",
    regexp = "java_runtime",
)

file_test(
    name = "rbe_autoconf_checked_in_cc_alias_no_java_test",
    file = "@rbe_autoconf_checked_in_no_java//test:cc/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_checked_in_java_runtime_no_cc_test",
    file = "@rbe_autoconf_checked_in_no_cc//test:java/test.BUILD",
    regexp = "java_runtime",
)

file_test(
    name = "rbe_autoconf_generate_cc_toolchain_test",
    file = "@rbe_autoconf_generate//test:cc/test.BUILD",
    regexp = "cc_toolchain(",
)

# TODO: Enable in CI
file_test(
    name = "rbe_autoconf_generate_cc_toolchain_windows_test",
    file = "@rbe_autoconf_generate_windows//test:cc/test.BUILD",
    regexp = "cc_toolchain(",
    tags = ["windows"],
)

# TODO: Enable in CI
file_test(
    name = "rbe_autoconf_generate_cc_toolchain_config_test",
    file = "@rbe_autoconf_generate//test:cc/test.BUILD",
    regexp = "cc_toolchain_config(",
)

# TODO: Enable in CI
file_test(
    name = "rbe_autoconf_generate_cc_toolchain_config_windows_test",
    file = "@rbe_autoconf_generate_windows//test:cc/test.BUILD",
    regexp = "cc_toolchain_config(",
    tags = ["windows"],
)

file_test(
    name = "rbe_autoconf_generate_cc_compiler_test",
    file = "@rbe_autoconf_generate//test:cc/test.BUILD",
    regexp = "cc-compiler-k8",
)

# TODO: Enable in CI
file_test(
    name = "rbe_autoconf_generate_cc_compiler_windows_test",
    file = "@rbe_autoconf_generate_windows//test:cc/test.BUILD",
    regexp = "cc-compiler-x64_windows",
    tags = ["windows"],
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
    regexp = "build @local_config_cc",
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
    regexp = "build @local_config_sh/",
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
    name = "rbe_autoconf_checked_in_platform_container_sha_test",
    file = "@rbe_autoconf_checked_in//test:config/test.BUILD",
    regexp = RBE_UBUNTU16_04_LATEST,
)

file_test(
    name = "rbe_autoconf_checked_in_platform_os_family_test",
    file = "@rbe_autoconf_checked_in//test:config/test.BUILD",
    regexp = "OSFamily",
)

file_test(
    name = "rbe_autoconf_generate_platform_test",
    file = "@rbe_autoconf_generate//test:config/test.BUILD",
    regexp = "platform",
)

# TODO: make rbe_repo automatically choose the correct constraint as default on Windows, no :linux constraints
# right now this passes b/c we're setting exec_compatible_with etc.
file_test(
    name = "rbe_autoconf_generate_platform_windows_test",
    file = "@rbe_autoconf_generate_windows//test:config/test.BUILD",
    regexp = "platforms:windows",
    tags = ["windows"],
)

# TODO: Enable in CI
file_test(
    name = "rbe_autoconf_generate_config_toolchain_windows_test",
    file = "@rbe_autoconf_generate_windows//test:config/test.BUILD",
    regexp = "toolchain.*=.*\".*:cc-compiler-x64_windows\"",
    tags = ["windows"],
)

file_test(
    name = "rbe_autoconf_checked_generate_container_sha_test",
    file = "@rbe_autoconf_generate//test:config/test.BUILD",
    regexp = RBE_UBUNTU16_04_LATEST,
)

# TODO: Enable in CI
file_test(
    name = "rbe_autoconf_checked_generate_container_sha_windows_test",
    file = "@rbe_autoconf_generate_windows//test:config/test.BUILD",
    regexp = "sha256:776f241c2693f3f2187d998dcc98d2b339dcb80c99ef59bccefad0eea6e61284",
    tags = ["windows"],
)

file_test(
    name = "rbe_autoconf_checked_generate_os_family_test",
    file = "@rbe_autoconf_generate//test:config/test.BUILD",
    regexp = "OSFamily",
)

# TODO: Enable in CI
file_test(
    name = "rbe_autoconf_checked_generate_os_family_windows_test",
    file = "@rbe_autoconf_generate_windows//test:config/test.BUILD",
    regexp = "value:.*\"Windows\"",
    tags = ["windows"],
)

file_test(
    name = "rbe_autoconf_old_container_platform_test",
    file = "@rbe_autoconf_old_container//test:config/test.BUILD",
    regexp = "platform",
)

file_test(
    name = "rbe_autoconf_old_container_container_sha_test",
    file = "@rbe_autoconf_old_container//test:config/test.BUILD",
    regexp = "87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c",
)

file_test(
    name = "rbe_autoconf_old_container_os_family_test",
    file = "@rbe_autoconf_old_container//test:config/test.BUILD",
    regexp = "OSFamily",
)

file_test(
    name = "rbe_autoconf_custom_container_platform_test",
    file = "@rbe_autoconf_custom_container//test:config/test.BUILD",
    regexp = "platform",
)

file_test(
    name = "rbe_autoconf_custom_container_sha_test",
    file = "@rbe_autoconf_custom_container//test:config/test.BUILD",
    regexp = "eb9f72ddde60080912fed8a6f40c5a42c13ec6c890c0709c119213b199804456",
)

file_test(
    name = "rbe_autoconf_custom_os_family_test",
    file = "@rbe_autoconf_custom_container//test:config/test.BUILD",
    regexp = "OSFamily",
)

file_test(
    name = "rbe_autoconf_generate_run_and_extract_test",
    file = "@rbe_autoconf_generate//test:run_and_extract.sh",
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
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "abi_libc_version = \"test_abi_libc_version_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_abi_version_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "abi_version = \"test_abi_version_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_bazel_host_system_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "host_system_name = \"test_bazel_host_system_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_bazel_target_cpu_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "cpu = \"test_bazel_target_cpu_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_bazel_target_libc_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "target_libc = \"test_bazel_target_libc_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_bazel_target_system_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "target_system_name = \"test_bazel_target_system_test\"",
)

file_test(
    name = "rbe_autoconf_custom_env_clang_toolchain_config_bzl_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
    regexp = "\"gcc\": \"/usr/local/bin/clang++\"",
)

file_test(
    name = "rbe_autoconf_custom_env_clang_toolchain_config_bzl_2_test",
    file = "@rbe_autoconf_custom_env//test:cc/test.BUILD",
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

# Tests that verify rbe_autoconfig with custom container +
# use of base_container_digest. Tests verify outputs correspond
# to a checked-in config and platform points to custom container
sh_test(
    name = "rbe_autoconf_base_container_digest_file_structure_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_base_container_digest//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_checked_in_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rbe_autoconf_base_container_digest//test:empty",
        "@rbe_autoconf_base_container_digest//test:exported_testdata",
    ],
)

file_test(
    name = "rbe_autoconf_base_container_digest_container_sha_test",
    file = "@rbe_autoconf_base_container_digest//test:config/test.BUILD",
    regexp = "b28ddaf98c6e0bb840c5fded3c0a899a7db45bb44f69859f16c37be092bfcb4e",
)

file_test(
    name = "rbe_autoconf_base_container_digest_os_family_test",
    file = "@rbe_autoconf_base_container_digest//test:config/test.BUILD",
    regexp = "OSFamily",
)

file_test(
    name = "rbe_autoconf_base_container_digest_cc_alias_test",
    file = "@rbe_autoconf_base_container_digest//test:cc/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_base_container_digest_java_runtime_test",
    file = "@rbe_autoconf_base_container_digest//test:java/test.BUILD",
    regexp = "java_runtime",
)

# Tests that verify rbe_autoconfig with custom exec_compatible_with
# and target_compatible_with attrs
file_test(
    name = "rbe_autoconf_constraints_exec_compatible_with_test",
    file = "@rbe_autoconf_constraints//test:config/test.BUILD",
    regexp = "//constraints:support_docker",
)

file_test(
    name = "rbe_autoconf_constraints_target_compatible_with_test",
    file = "@rbe_autoconf_constraints//test:config/test.BUILD",
    regexp = "//constraints:xenial",
)

# Test to verify tag is resolved to digest properly
file_test(
    name = "rbe_autoconf_resovle_tag_test",
    file = "@rbe_autoconf_resovle_tag//test:config/test.BUILD",
    regexp = "9596a8fbd6a6a77b2fe1272b145235b43f516b4f86eb470d5ee99b738ce37994",
)

# Tests for output_base. These require RBE_AUTOCONF_ROOT env variable to be set
sh_test(
    name = "rbe_autoconf_output_base_test",
    srcs = [":rbe_autoconf_output_base_config_dir_checks.sh"],
    args = [
        "$(location @rbe_autoconf_output_base//test:empty)",
        "rbe-test-output/config/rbe_autoconf_output_base",
        "9.0.0",
        _ubuntu1604_bazel,
        "assert_output_base_cc_confs",
        "assert_output_base_java_confs",
        "assert_output_base_platform_confs",
    ],
    data = [
        ":rbe_autoconf_checks.sh",
        "@rbe_autoconf_output_base//test:empty",
        "@rbe_autoconf_output_base//test:exported_testdata",
    ],
)

# TODO: Enable in CI and remove hardcoded Bazel version
sh_test(
    name = "rbe_autoconf_output_base_windows_test",
    srcs = [":rbe_autoconf_output_base_config_dir_checks.sh"],
    args = [
        "$(location @rbe_autoconf_output_base_windows//test:empty)",
        "rbe-test-output/config/rbe_autoconf_output_base_windows",
        "test_config_dir",
        "3.1.0",
        "assert_output_base_cc_confs_windows",
        "assert_output_base_platform_confs",
    ],
    data = [
        ":rbe_autoconf_checks.sh",
        "@rbe_autoconf_output_base_windows//test:empty",
        "@rbe_autoconf_output_base_windows//test:exported_testdata",
    ],
    tags = ["windows"],
)

file_test(
    name = "rbe_autoconf_output_base_test_cc_alias_test",
    file = "@rbe_autoconf_output_base//test:cc/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_output_base_test_java_alias_test",
    file = "@rbe_autoconf_output_base//test:java/test.BUILD",
    regexp = "alias",
)

sh_test(
    name = "rbe_autoconf_output_base_external_repo_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_output_base//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_checked_in_cc_confs",
        "assert_java_confs",
        "assert_no_configs_tar",
    ],
    data = [
        "@rbe_autoconf_output_base//test:empty",
        "@rbe_autoconf_output_base//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_output_base_no_java_test",
    srcs = [":rbe_autoconf_output_base_config_dir_checks.sh"],
    args = [
        "$(location @rbe_autoconf_output_base_no_java//test:empty)",
        "rbe-test-output/config/rbe_autoconf_output_base_no_java",
        _ubuntu1604_bazel,
        "assert_output_base_cc_confs",
        "assert_output_base_no_java_confs",
        "assert_output_base_platform_confs",
    ],
    data = [
        ":rbe_autoconf_checks.sh",
        "@rbe_autoconf_output_base_no_java//test:empty",
        "@rbe_autoconf_output_base_no_java//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_output_base_no_cc_test",
    srcs = [":rbe_autoconf_output_base_config_dir_checks.sh"],
    args = [
        "$(location @rbe_autoconf_output_base_no_cc//test:empty)",
        "rbe-test-output/config/rbe_autoconf_output_base_no_cc",
        "9.0.0",
        _ubuntu1604_bazel,
        "assert_output_base_no_cc_confs",
        "assert_output_base_java_confs",
        "assert_output_base_platform_confs",
    ],
    data = [
        ":rbe_autoconf_checks.sh",
        "@rbe_autoconf_output_base_no_cc//test:empty",
        "@rbe_autoconf_output_base_no_cc//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_config_repos_output_base_test",
    srcs = [":rbe_autoconf_output_base_config_dir_checks.sh"],
    args = [
        "$(location @rbe_autoconf_config_repos_output_base//test:empty)",
        "rbe-test-output/config/rbe_autoconf_config_repos_output_base",
        "9.0.0",
        _ubuntu1604_bazel,
        "assert_output_base_cc_confs",
        "assert_output_base_java_confs",
        "assert_output_base_platform_confs",
        "assert_output_base_custom_confs",
    ],
    data = [
        ":rbe_autoconf_checks.sh",
        "@rbe_autoconf_config_repos_output_base//test:empty",
        "@rbe_autoconf_config_repos_output_base//test:exported_testdata",
    ],
)

file_test(
    name = "rbe_autoconf_config_repos_output_base_run_in_container_test",
    file = "@rbe_autoconf_config_repos_output_base//test:container/run_in_container.sh",
    regexp = "build @local_config_cc//... @local_config_sh//...",
)

# Tests for output_base + config_dir. These require RBE_AUTOCONF_ROOT env
# variable to be set
sh_test(
    name = "rbe_autoconf_output_base_config_dir_test",
    srcs = [":rbe_autoconf_output_base_config_dir_checks.sh"],
    args = [
        "$(location @rbe_autoconf_output_base_config_dir//test:empty)",
        "rbe-test-output/config/rbe_autoconf_output_base",
        "test_config_dir",
        _ubuntu1604_bazel,
        "assert_output_base_cc_confs",
        "assert_output_base_java_confs",
        "assert_output_base_platform_confs",
    ],
    data = [
        ":rbe_autoconf_checks.sh",
        "@rbe_autoconf_output_base_config_dir//test:empty",
        "@rbe_autoconf_output_base_config_dir//test:exported_testdata",
    ],
)

# tests to validate docker image was / was not pulled
sh_test(
    name = "rbe_autoconf_generate_no_docker_pull_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_generate_no_docker_pull//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_java_confs",
        "assert_no_java_home",
        "assert_image_not_pulled",
    ],
    data = [
        "@rbe_autoconf_generate_no_docker_pull//test:empty",
        "@rbe_autoconf_generate_no_docker_pull//test:exported_testdata",
    ],
)

file_test(
    name = "rbe_autoconf_generate_image_name_test",
    file = "@rbe_autoconf_generate//test:image_name",
    regexp = RBE_UBUNTU16_04_LATEST,
)

# Tests for rbe_autoconfig when using a custom
# toolchain_config_suite_spec.

# tests that use rbe_autoconf_custom_toolchain_config_suite_spec
# validate it uses checked in configs when a custom versions.bzl
# file is used.
sh_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_custom_toolchain_config_suite_spec//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_checked_in_cc_confs",
        "assert_java_confs",
        "assert_no_java_home",
    ],
    data = [
        "@rbe_autoconf_custom_toolchain_config_suite_spec//test:empty",
        "@rbe_autoconf_custom_toolchain_config_suite_spec//test:exported_testdata",
    ],
)

file_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_cc_alias_test",
    file = "@rbe_autoconf_custom_toolchain_config_suite_spec//test:cc/test.BUILD",
    regexp = "alias",
)

file_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_java_alias_test",
    file = "@rbe_autoconf_custom_toolchain_config_suite_spec//test:java/test.BUILD",
    regexp = "java_runtime",
)

file_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_platform_test",
    file = "@rbe_autoconf_custom_toolchain_config_suite_spec//test:config/test.BUILD",
    regexp = "platform",
)

file_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_platform_container_sha_test",
    file = "@rbe_autoconf_custom_toolchain_config_suite_spec//test:config/test.BUILD",
    regexp = test_toolchain_config_suite_autogen_spec.latest_container,
)

# tests that use rbe_autoconf_custom_toolchain_config_suite_spec_export
# validate it generates configs when a custom versions.bzl
# file is used.
sh_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_export_test",
    srcs = [":rbe_autoconf_output_base_config_dir_checks.sh"],
    args = [
        "$(location @rbe_autoconf_custom_toolchain_config_suite_spec_export//test:empty)",
        "rbe-test-output/config/rbe_autoconf_custom_toolchain_config_suite_spec_export",
        "test_config_dir",
        _ubuntu1604_bazel,
        "assert_output_base_cc_confs",
        "assert_output_base_java_confs",
        "assert_output_base_platform_confs",
    ],
    data = [
        ":rbe_autoconf_checks.sh",
        "@rbe_autoconf_custom_toolchain_config_suite_spec_export//test:empty",
        "@rbe_autoconf_custom_toolchain_config_suite_spec_export//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_export_external_repo_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_custom_toolchain_config_suite_spec_export//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_checked_in_cc_confs",
        "assert_java_confs",
        "assert_no_configs_tar",
    ],
    data = [
        "@rbe_autoconf_custom_toolchain_config_suite_spec_export//test:empty",
        "@rbe_autoconf_custom_toolchain_config_suite_spec_export//test:exported_testdata",
    ],
)

# tests that use rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions
# validate it generates configs when a blank versions.bzl
# file is used.
sh_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions_test",
    srcs = [":rbe_autoconf_output_base_config_dir_checks.sh"],
    args = [
        "$(location @rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions//test:empty)",
        "rbe-test-output/config/rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions",
        "default_toolchain_config_spec_name",
        _ubuntu1604_bazel,
        "assert_output_base_cc_confs",
        "assert_output_base_java_confs",
        "assert_output_base_platform_confs",
    ],
    data = [
        ":rbe_autoconf_checks.sh",
        "@rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions//test:empty",
        "@rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions//test:exported_testdata",
    ],
)

sh_test(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions_external_repo_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_checked_in_cc_confs",
        "assert_java_confs",
        "assert_no_configs_tar",
    ],
    data = [
        "@rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions//test:empty",
        "@rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions//test:exported_testdata",
    ],
)

# Verifies that all containers listed in the versions.bzl file used by
# rbe_autoconfig are available for pulling.
# This test requires docker to be present on the path.
sh_test(
    name = "rbe_container_test",
    size = "large",
    srcs = [":rbe_container_test.sh"],
    args = [(("{}/{}@{}").format(
        # use l.gcr.io to test with no auth required
        "l.gcr.io",
        default_toolchain_config_suite_spec()["container_repo"],
        sha256,
    )) for sha256 in RBE_CONTAINERS_MAP.keys()],
    tags = ["no-remote"],
)
