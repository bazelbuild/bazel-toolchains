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

load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig", "rbe_autoconfig_root")

rbe_autoconfig(name = "rbe_default")

rbe_autoconfig(
    name = "rbe_default_copy_resources",
    copy_resources = True,
)

# Targets used by automatic config generation and release service.
load(
    "//configs/dependency-tracking:ubuntu1604.bzl",
    _ubuntu1604_bazel = "bazel",
    _ubuntu1604_configs_version = "configs_version",
    _ubuntu1604_digest = "digest",
    _ubuntu1604_registry = "registry",
    _ubuntu1604_repository = "repository",
)

# Automatic config generation target for RBE Ubuntu 16.04
rbe_autoconfig(
    name = "rbe_autoconfig_autogen_ubuntu1604",
    bazel_version = _ubuntu1604_bazel,
    digest = _ubuntu1604_digest,
    output_base = "configs/ubuntu16_04_clang/{}".format(_ubuntu1604_configs_version),
    registry = _ubuntu1604_registry,
    repository = _ubuntu1604_repository,
    use_checked_in_confs = False,
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

# Automatic E2E test config generation target for RBE Ubuntu 16.04 that should
# generate new configs because dependencies have changed.
rbe_autoconfig(
    name = "rbe_ubuntu1604_trigger_config_gen_test",
    bazel_version = _bazel_trigger_config_gen,
    digest = _digest_trigger_config_gen,
    output_base = "tests/config/trigger_config_gen/{}".format(_configs_version_trigger_config_gen),
    registry = _registry_trigger_config_gen,
    repository = _repository_trigger_config_gen,
    use_checked_in_confs = False,
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
    output_base = "tests/config/no_updates/{}".format(_configs_version_no_updates),
    registry = _registry_no_updates,
    repository = _repository_no_updates,
    use_checked_in_confs = False,
)

load("//rules:environments.bzl", "clang_env")
load("@bazel_skylib//lib:dicts.bzl", "dicts")

rbe_autoconfig(
    name = "rbe_msan_with_output_base",
    config_dir = "msan",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    output_base = "configs/ubuntu16_04_clang/1.1",
)

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
    base_container_digest = "sha256:bc6a2ad47b24d01a73da315dd288a560037c51a95cc77abb837b26fef1408798",
    # Note that if you change the `digest`, you might also need to update the
    # `base_container_digest` to make sure asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud:<digest>
    # and marketplace.gcr.io/google/rbe-ubuntu16-04:<base_container_digest> have the
    # same Clang and JDK installed.
    digest = "sha256:ab88c40463d782acc4289948fe0b1577de0b143a753cea35cac34535203f8ca7",
    env = clang_env(),
    registry = "gcr.io",
    repository = "asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud",
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
    use_checked_in_confs = False,
)

rbe_autoconfig(
    name = "rbe_autoconf_generate_no_java",
    bazel_version = _ubuntu1604_bazel,
    create_java_configs = False,
    create_testdata = True,
    use_checked_in_confs = False,
)

rbe_autoconfig(
    name = "rbe_autoconf_generate_no_cc",
    bazel_version = _ubuntu1604_bazel,
    create_cc_configs = False,
    create_testdata = True,
    use_checked_in_confs = False,
)

rbe_autoconfig(
    name = "rbe_autoconf_copy_resources",
    bazel_version = _ubuntu1604_bazel,
    copy_resources = True,
    create_testdata = True,
    use_checked_in_confs = False,
)

rbe_autoconfig(
    name = "rbe_autoconf_config_repos",
    bazel_version = _ubuntu1604_bazel,
    config_repos = ["local_config_sh"],
    create_testdata = True,
    use_checked_in_confs = False,
)
  
rbe_autoconfig(
    name = "rbe_autoconf_config_repos_no_cc_config",
    bazel_version = _ubuntu1604_bazel,
    config_repos = ["local_config_sh"],
    create_cc_configs = False,
    create_testdata = True,
    use_checked_in_confs = False,
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
    digest = "sha256:ab88c40463d782acc4289948fe0b1577de0b143a753cea35cac34535203f8ca7",
    env = clang_env(),
    registry = "gcr.io",
    repository = "asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud",
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
    output_base = "tests/config/rbe_autoconf_output_base",
    use_checked_in_confs = False,
)

rbe_autoconfig(
    name = "rbe_autoconf_config_repos_output_base",
    bazel_version = _ubuntu1604_bazel,
    config_repos = [
        "local_config_sh", 
        "bazel_skylib",
    ],
    create_testdata = True,
    output_base = "tests/config/rbe_autoconf_config_repos_output_base",
    use_checked_in_confs = False,
)

# Needed for testing purposes. Creates a file that exposes
# the value of RBE_AUTOCONF_ROOT
rbe_autoconfig_root(name = "rbe_autoconfig_root")
