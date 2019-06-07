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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(
    "//repositories:repositories.bzl",
    bazel_toolchains_repositories = "repositories",
)

bazel_toolchains_repositories()

load(
    "@io_bazel_rules_docker//toolchains/docker:toolchain.bzl",
    docker_toolchain_configure = "toolchain_configure",
)

docker_toolchain_configure(
    name = "docker_config",
    docker_path = "/usr/bin/docker",
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)
load(
    "//repositories:images.bzl",
    bazel_toolchains_images = "images",
)

bazel_toolchains_images()

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

container_pull(
    name = "official_jessie",
    registry = "index.docker.io",
    repository = "library/debian",
    tag = "jessie",
)

container_pull(
    name = "official_xenial",
    registry = "index.docker.io",
    repository = "library/ubuntu",
    tag = "16.04",
)

# Pinned to marketplace.gcr.io/google/clang-ubuntu@sha256:ab3f65314c94279e415926948f8428428e3b6057003f15197ffeae0b1b5a2386
# solely for testing purpose used by //tests/config:ubuntu16_04_clang_autoconfig_test.
container_pull(
    name = "ubuntu16_04-clang-test",
    digest = "sha256:ab3f65314c94279e415926948f8428428e3b6057003f15197ffeae0b1b5a2386",
    registry = "marketplace.gcr.io",
    repository = "google/clang-ubuntu",
)

# Test purpose only. bazel-toolchains repo at release for Bazel 0.24.0.
# https://github.com/bazelbuild/bazel-toolchains/releases/tag/cddc376
http_file(
    name = "bazel_toolchains_test",
    downloaded_file_path = "cddc376d428ada2927ad359211c3e356bd9c9fbb.tar.gz",
    sha256 = "67335b3563d9b67dc2550b8f27cc689b64fadac491e69ce78763d9ba894cc5cc",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/cddc376d428ada2927ad359211c3e356bd9c9fbb.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/cddc376d428ada2927ad359211c3e356bd9c9fbb.tar.gz",
    ],
)

# Download test file to test gcs_file rule
load("//rules:gcs.bzl", "gcs_file")

gcs_file(
    name = "download_test_gcs_file",
    bucket = "gs://bazel-toolchains-test",
    downloaded_file_path = "test.txt",
    file = "test.txt",
    sha256 = "5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9",
)

load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig")

# Targets used by automatic config generation and release service.
load(
    "//configs/dependency-tracking:ubuntu1604.bzl",
    _ubuntu1604_bazel = "bazel",
    _ubuntu1604_configs_version = "configs_version",
    _ubuntu1604_digest = "digest",
    _ubuntu1604_registry = "registry",
    _ubuntu1604_repository = "repository",
)

# Default target used in tests that run with several Bazel versions
rbe_autoconfig(
    name = "rbe_default",
)

# Automatic config generation target for RBE Ubuntu 16.04
rbe_autoconfig(
    name = "rbe_default_gen",
    digest = _ubuntu1604_digest,
    export_configs = True,
    registry = _ubuntu1604_registry,
    repository = _ubuntu1604_repository,
    toolchain_config_spec_name = _ubuntu1604_configs_version,
)

# Legacy config generation target. To be removed once toolchain config service
# is updated.
# TODO(nlopezgi): remove this target after migration.
rbe_autoconfig(
    name = "rbe_autoconfig_autogen_ubuntu1604",
    create_versions = False,
    digest = _ubuntu1604_digest,
    export_configs = True,
    registry = _ubuntu1604_registry,
    repository = _ubuntu1604_repository,
    toolchain_config_spec_name = _ubuntu1604_configs_version,
    use_checked_in_confs = "False",
)

# RBE Autoconfig targets to do integration testing on the automatic toolchain
# configs release process.
load(
    "//tests/config/dependency-tracking:trigger_config_gen.bzl",
    _bazel_trigger_config_gen = "bazel",
    _configs_version_trigger_config_gen = "configs_version",
    _digest_trigger_config_gen = "digest",
    _registry_trigger_config_gen = "registry",
    _repository_trigger_config_gen = "repository",
)
load("//rules/rbe_repo:util.bzl", "rbe_autoconfig_root")
load(
    "//rules/rbe_repo:toolchain_config_suite_spec.bzl",
    rbe_default_repo = "default_toolchain_config_suite_spec",
)

# Automatic E2E test config generation target for RBE Ubuntu 16.04 that should
# generate new configs because dependencies have changed.
rbe_autoconfig(
    name = "rbe_ubuntu1604_trigger_config_gen_test",
    bazel_version = _bazel_trigger_config_gen,
    digest = _digest_trigger_config_gen,
    export_configs = True,
    registry = _registry_trigger_config_gen,
    repository = _repository_trigger_config_gen,
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "tests/config/trigger_config_gen/{}".format(_configs_version_trigger_config_gen),
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": rbe_default_repo()["toolchain_config_suite_autogen_spec"],
    },
    use_checked_in_confs = "False",
)

load(
    "//tests/config/dependency-tracking:no_updates.bzl",
    _bazel_no_updates = "bazel",
    _configs_version_no_updates = "configs_version",
    _digest_no_updates = "digest",
    _registry_no_updates = "registry",
    _repository_no_updates = "repository",
)

# Automatic E2E test config generation target for RBE Ubuntu 16.04 that should
# not generate any new configs.
rbe_autoconfig(
    name = "rbe_ubuntu1604_configs_no_update_test",
    bazel_version = _bazel_no_updates,
    digest = _digest_no_updates,
    export_configs = True,
    registry = _registry_no_updates,
    repository = _repository_no_updates,
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "tests/config/no_updates/{}".format(_configs_version_no_updates),
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": rbe_default_repo()["toolchain_config_suite_autogen_spec"],
    },
    use_checked_in_confs = "False",
)

load("//rules:environments.bzl", "clang_env")

# Use in the RBE Ubuntu1604 container release.
rbe_autoconfig(
    name = "rbe_ubuntu1604_test",
    env = clang_env(),
    registry = "gcr.io",
    repository = "asci-toolchain/test-rbe-ubuntu16_04",
    tag = "latest",
)

# Use in the BazelCI.
rbe_autoconfig(
    name = "buildkite_config",
)

# Targets below for purposes of testing of rbe_autoconfig rule only

rbe_autoconfig(
    name = "rbe_autoconf_checked_in",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
)

rbe_autoconfig(
    name = "rbe_autoconf_checked_in_no_java",
    bazel_version = _ubuntu1604_bazel,
    create_java_configs = False,
    create_testdata = True,
)

rbe_autoconfig(
    name = "rbe_autoconf_checked_in_no_cc",
    bazel_version = _ubuntu1604_bazel,
    create_cc_configs = False,
    create_testdata = True,
)

rbe_autoconfig(
    name = "rbe_autoconf_generate",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    use_checked_in_confs = "False",
)

rbe_autoconfig(
    name = "rbe_autoconf_generate_no_java",
    bazel_version = _ubuntu1604_bazel,
    create_java_configs = False,
    create_testdata = True,
    use_checked_in_confs = "False",
)

rbe_autoconfig(
    name = "rbe_autoconf_generate_no_cc",
    bazel_version = _ubuntu1604_bazel,
    create_cc_configs = False,
    create_testdata = True,
    use_checked_in_confs = "False",
)

rbe_autoconfig(
    name = "rbe_autoconf_no_copy_resources",
    bazel_version = _ubuntu1604_bazel,
    copy_resources = False,
    create_testdata = True,
    use_checked_in_confs = "False",
)

rbe_autoconfig(
    name = "rbe_autoconf_config_repos",
    bazel_version = _ubuntu1604_bazel,
    config_repos = ["local_config_sh"],
    create_testdata = True,
)

rbe_autoconfig(
    name = "rbe_autoconf_config_repos_no_cc_config",
    bazel_version = _ubuntu1604_bazel,
    config_repos = ["local_config_sh"],
    create_cc_configs = False,
    create_testdata = True,
)

rbe_autoconfig(
    name = "rbe_autoconf_custom_java_home",
    bazel_version = _ubuntu1604_bazel,
    create_cc_configs = False,
    create_testdata = True,
    java_home = "test-case-java-home",
)

rbe_autoconfig(
    name = "rbe_autoconf_old_container",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    digest = "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c",
    registry = _ubuntu1604_registry,
    repository = _ubuntu1604_repository,
)

rbe_autoconfig(
    name = "rbe_autoconf_custom_container",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    digest = "sha256:cda3a8608d0fc545dffc6c68f6cfab8eda280c7a1558bde0753ed2e8e3006224",
    registry = _ubuntu1604_registry,
    repository = "google/rbe-debian8",
)

rbe_autoconfig(
    name = "rbe_autoconf_custom_env",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    env = {
        "ABI_LIBC_VERSION": "test_abi_libc_version_test",
        "ABI_VERSION": "test_abi_version_test",
        "BAZEL_COMPILER": "clang++",
        "BAZEL_HOST_SYSTEM": "test_bazel_host_system_test",
        "BAZEL_TARGET_CPU": "test_bazel_target_cpu_test",
        "BAZEL_TARGET_LIBC": "test_bazel_target_libc_test",
        "BAZEL_TARGET_SYSTEM": "test_bazel_target_system_test",
        "CC": "clang++",
        "CC_TOOLCHAIN_NAME": "test_cc_toolchain_name_test",
    },
)

rbe_autoconfig(
    name = "rbe_autoconf_base_container_digest",
    base_container_digest = "sha256:bc6a2ad47b24d01a73da315dd288a560037c51a95cc77abb837b26fef1408798",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    digest = "sha256:1fcb66b2d451b453aa7e9ef0798823c657fa0f5b3a6b52f607cc6da1e68a11ca",
    env = clang_env(),
    registry = "marketplace.gcr.io",
    repository = "google/bazel",
)

rbe_autoconfig(
    name = "rbe_autoconf_constraints",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    exec_compatible_with = [
        "//constraints:support_docker",
    ],
    target_compatible_with = [
        "//constraints:xenial",
    ],
)

rbe_autoconfig(
    name = "rbe_autoconf_resovle_tag",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    registry = "marketplace.gcr.io",
    repository = "google/bazel",
    tag = "0.23.2",
)

rbe_autoconfig(
    name = "rbe_autoconf_output_base",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    export_configs = True,
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "rbe-test-output/config/rbe_autoconf_output_base",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": rbe_default_repo()["toolchain_config_suite_autogen_spec"],
    },
    use_checked_in_confs = "False",
)

rbe_autoconfig(
    name = "rbe_autoconf_output_base_no_java",
    bazel_version = _ubuntu1604_bazel,
    create_java_configs = False,
    create_testdata = True,
    export_configs = True,
    toolchain_config_spec_name = "rbe_autoconf_output_base_no_java",
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "rbe-test-output/config/rbe_autoconf_output_base_no_java",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": rbe_default_repo()["toolchain_config_suite_autogen_spec"],
    },
    use_checked_in_confs = "False",
)

rbe_autoconfig(
    name = "rbe_autoconf_output_base_no_cc",
    bazel_version = _ubuntu1604_bazel,
    create_cc_configs = False,
    create_testdata = True,
    export_configs = True,
    toolchain_config_spec_name = "rbe_autoconf_output_base_no_cc",
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "rbe-test-output/config/rbe_autoconf_output_base_no_cc",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": rbe_default_repo()["toolchain_config_suite_autogen_spec"],
    },
    use_checked_in_confs = "False",
)

rbe_autoconfig(
    name = "rbe_autoconf_config_repos_output_base",
    bazel_version = _ubuntu1604_bazel,
    config_repos = [
        "local_config_sh",
    ],
    create_testdata = True,
    export_configs = True,
    toolchain_config_spec_name = "rbe_autoconf_config_repos_output_base",
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "rbe-test-output/config/rbe_autoconf_config_repos_output_base",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": rbe_default_repo()["toolchain_config_suite_autogen_spec"],
    },
    use_checked_in_confs = "False",
)

rbe_autoconfig(
    name = "rbe_autoconf_output_base_config_dir",
    bazel_version = _ubuntu1604_bazel,
    create_testdata = True,
    toolchain_config_spec_name = "test_config_dir",
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "rbe-test-output/config/rbe_autoconf_output_base",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": rbe_default_repo()["toolchain_config_suite_autogen_spec"],
    },
    use_checked_in_confs = "False",
)

# Test to validate no docker image is pulled when a custom container
# is used where no cc_configs are needed and java_home is passed
# explicitly.
rbe_autoconfig(
    name = "rbe_autoconf_generate_no_docker_pull",
    bazel_version = _ubuntu1604_bazel,
    create_cc_configs = False,
    create_testdata = True,
    digest = "sha256:ab88c40463d782acc4289948fe0b1577de0b143a753cea35cac34535203f8ca7",
    env = clang_env(),
    java_home = "test-case-java-home",
    registry = "gcr.io",
    repository = "asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud",
)

load(
    "//tests/rbe_repo:versions_test.bzl",
    test_toolchain_config_suite_autogen_spec = "TOOLCHAIN_CONFIG_AUTOGEN_SPEC",
)

rbe_autoconfig(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec",
    bazel_version = "0.26.0",
    create_testdata = True,
    toolchain_config_spec_name = "testConfigSpecName1",
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "rbe-test-output/config/rbe_autoconf_custom_toolchain_config_suite_spec",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": test_toolchain_config_suite_autogen_spec,
    },
    use_checked_in_confs = "Force",
)

rbe_autoconfig(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_export",
    create_testdata = True,
    export_configs = True,
    toolchain_config_spec_name = "test_config_dir",
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "rbe-test-output/config/rbe_autoconf_custom_toolchain_config_suite_spec_export",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": test_toolchain_config_suite_autogen_spec,
    },
)

load(
    "//tests/rbe_repo:blank_versions_test.bzl",
    blank_toolchain_config_suite_autogen_spec = "TOOLCHAIN_CONFIG_AUTOGEN_SPEC",
)

rbe_autoconfig(
    name = "rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions",
    create_testdata = True,
    export_configs = True,
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "rbe-test-output/config/rbe_autoconf_custom_toolchain_config_suite_spec_blank_versions",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": blank_toolchain_config_suite_autogen_spec,
    },
)

load(
    "//tests/rbe_repo:versions.bzl",
    gcb_test_toolchain_config_suite_autogen_spec = "TOOLCHAIN_CONFIG_AUTOGEN_SPEC",
)

# This repo should only be used for GCB tests.
# It relies on location of //tests/rbe_repo:blank_versions_test.bzl
# and output_base in toolchain_config_suite_spec to match so that 1st build
# should create configs, and subsequent ones should reuse them
# (even when bazel cache is not maintained from one step to the next)
rbe_autoconfig(
    name = "rbe_autoconf_gcb_test",
    create_testdata = True,
    export_configs = True,
    toolchain_config_suite_spec = {
        "container_registry": rbe_default_repo()["container_registry"],
        "container_repo": rbe_default_repo()["container_repo"],
        "output_base": "tests/rbe_repo",
        "repo_name": rbe_default_repo()["repo_name"],
        "toolchain_config_suite_autogen_spec": gcb_test_toolchain_config_suite_autogen_spec,
    },
)

# Needed for testing purposes. Creates a file that exposes
# the value of RBE_AUTOCONF_ROOT
rbe_autoconfig_root(name = "rbe_autoconfig_root")

# Pull in dependencies of base_images_docker.
load("@base_images_docker//package_managers:repositories.bzl", package_manager_deps = "deps")

package_manager_deps()

load("@io_bazel_rules_python//python:pip.bzl", "pip_import", "pip_repositories")

pip_repositories()

pip_import(
    name = "pip_deps",
    requirements = "@base_images_docker//package_managers:requirements-pip.txt",
)

load("@pip_deps//:requirements.bzl", "pip_install")

pip_install()
