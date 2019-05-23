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
"""Exposes def to valiate if checked-in confs can be used in rbe_autoconf."""

load("//rules:environments.bzl", "clang_env")
load(
    "//configs/ubuntu16_04_clang:versions.bzl",
    "bazel_to_config_versions",
    RBE_UBUNTU16_04_LATEST = "LATEST",
    rbe_ubuntu16_04_config_version = "container_to_config_version",
)

RBE_UBUNTU_REPO = "google/rbe-ubuntu16-04"
RBE_UBUNTU_REGISTRY = "marketplace.gcr.io"

CHECKED_IN_CONFS_TRY = "Try"
CHECKED_IN_CONFS_FORCE = "Force"
CHECKED_IN_CONFS_FALSE = "False"
CHECKED_IN_CONFS_VALUES = [
    CHECKED_IN_CONFS_TRY,
    CHECKED_IN_CONFS_FORCE,
    CHECKED_IN_CONFS_FALSE,
]

def validateUseOfCheckedInConfigs(
        name,
        base_container_digest,
        bazel_version,
        bazel_rc_version,
        create_java_configs,
        digest,
        env,
        java_home,
        registry,
        repository,
        tag,
        use_checked_in_confs):
    """Check if checked-in configs are available and should be used.

    If so, return the config version. Otherwise return None.

    Args:
        name: Name of the rule target.
        base_container_digest: SHA256 sum digest of the base image.
        bazel_version: Version string of the Bazel release.
        bazel_rc_version: The RC version of the Bazel release if the given
                          Bazel release is a RC.
        digest: The digest of the container in which the configs are goings to
                be used.
        env: The environment dict.
        create_java_configs: Whether java config generation is enabled.
        java_home: Path to the Java home.
        registry: The registry where the toolchain container can be found.
        repository: The path to the toolchain container on the registry.
        tag: The tag on the toolchain container.
        use_checked_in_confs: Whether to use checked in configs.

    Returns:
        None
    """
    if use_checked_in_confs == CHECKED_IN_CONFS_FALSE:
        return None
    if not base_container_digest and registry and registry != RBE_UBUNTU_REGISTRY:
        return None
    if not base_container_digest and repository and repository != RBE_UBUNTU_REPO:
        return None
    if env and env != clang_env():
        return None
    if create_java_configs and java_home:
        return None
    if bazel_rc_version:
        return None

    if tag:  # Implies `digest` is not specified.
        if tag == "latest":
            digest = RBE_UBUNTU16_04_LATEST
            # if any tag other than latest is used we will not use checked-in configs
            # (to not hardcode tag info anywhere in these rules)

        else:
            return None

    if base_container_digest:
        digest = base_container_digest

    # Verify a toolchain config exists for the given version of Bazel and the
    # given digest of the container
    config_version = rbe_ubuntu16_04_config_version().get(digest, None)
    if not config_version:
        return None
    if not bazel_to_config_versions().get(bazel_version):
        return None
    for supported_config in bazel_to_config_versions().get(bazel_version):
        if config_version == supported_config:
            return config_version
    return None
