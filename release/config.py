# Copyright 2016 The Bazel Authors. All rights reserved.
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
"""Data structures of toolchain configs."""

import os


class ContainerConfigs(object):
  """Group of configs that are generated using the same container.

  Attributes:
    distro: string, base distro of container used to generate configs.
    version: string, version of the configs.
    image: string, the container registry entry of the image used to generated
      the configs, e.g. marketplace.gcr.io/google/clang-ubuntu.
    package: string, the Bazel package in which we will generate the target to
      build configs.
    platform_target: string, the platform target name of the corresponding RBE
      container these configs will be used together with, e.g. rbe_ubuntu1604.
      This is required to set value for flags: --extra_execution_platforms,
        --host_platform and --platforms.
        (Platform: https://docs.bazel.build/versions/master/platforms.html)
    constraints: string, additional toolchain constraints needed for the cpp
      toolchain definition. These must be valid targets in this repo or
      @bazel_tools.
      (Toolchain: https://docs.bazel.build/versions/master/toolchains.html)
    configs: list of Config object, a list of configs for each supported types
      generated using the container specified in the current ContainerConfig.
  """

  # Currently supported distros.
  _SUPPORTED_DISTROS = ["debian8", "ubuntu16_04"]

  # Map from the container distro to additional pre-defined cpp toolchain
  # definition constraints.
  _DISTRO_CONSTRAINTS_MAP = {
      "debian8": ["//constraints:jessie"],
      "ubuntu16_04": ["//constraints:xenial"]
  }

  def __init__(self, distro, version, image, package, config_types,
               platform_target, git_root, bazel_version):
    """Inits ContainerConfigs.

    Args:
      distro: string, base distro of container used to generate configs.
      version: string, version of the configs.
      image: string, the container registry entry of the image used to generated
        the configs, e.g. marketplace.gcr.io/google/clang-ubuntu.
      package: string, the Bazel package in which we will generate the target to
        build configs.
      config_types: types of config to generated with this container, e.g.
        default, msan.
      platform_target: string, the platform target name of the corresponding RBE
        container these configs will be used together with  e.g. rbe_ubuntu1604.
        This is required to set value for flags: --extra_execution_platforms,
          --host_platform and --platforms.
          (Platform: https://docs.bazel.build/versions/master/platforms.html)
      git_root: the absolute path of the root directory of the current
        repository.
      bazel_version: the version of Bazel used to generated the configs.

    Returns:
      A ContainerConfigs object.
    Raises:
      ValueError: An error occurred when input distro is not supported.
    """

    # Validate distro is supported.
    if distro not in ContainerConfigs._SUPPORTED_DISTROS:
      raise ValueError(
          "Input distro: %s is not supported. Supported distros are %s" %
          (distro, " ".join(ContainerConfigs._SUPPORTED_DISTROS)))

    self._git_root = git_root
    self._bazel_version = bazel_version

    self.distro = distro
    self.version = version
    self.image = image
    self.package = package
    self.platform_target = platform_target
    self.constraints = ContainerConfigs._DISTRO_CONSTRAINTS_MAP[distro]
    self.config_types = config_types

    self.configs = [
        Config(root=self._get_config_base_dir(), config_type=config_type)
        for config_type in config_types
    ]

  def get_target_build_path(self):
    """Returns the absolute path of the target BUILD file."""
    return os.path.join(self._git_root, self.package, "BUILD")

  def get_latest_aliases_build_path(self):
    """Returns the absolute path of BUILD file with latest target aliases."""
    return os.path.join(self._git_root, self.package, "latest", "BUILD")

  def get_toolchain_bazelrc_path(self):
    """Returns the absolute path of the toolchain.bazelrc file."""
    return os.path.join(self._git_root, self.package, self.version,
                        "toolchain.bazelrc")

  def get_platform_build_path(self):
    """Returns the absolute path of BUILD file with platform definition."""
    return os.path.join(self._git_root, self.package, self.version, "BUILD")

  def get_java_runtime_build_path(self):
    """Returns the absolute path of BUILD file with java runtime."""
    return self.get_platform_build_path()

  def get_cpp_build_path(self):
    """Returns the absolute path of BUILD file with cpp toolchain definition."""
    return os.path.join(self._get_config_base_dir(), "cpp", "BUILD")

  def _get_config_base_dir(self):
    """Returns the absolute path of bazel_{version} directory.

    This returns the absolute path of bazel_{version} directory where configs
    are stored in the bazel-toolchains repo.

    For example: /.../configs/ubuntu16_04_clang/1.0/bazel_0.15.0/
    """
    return os.path.join(self._git_root, self.package, self.version,
                        "bazel_%s" % self._bazel_version)


class Config(object):
  """Configs of a single type that are generated using a container.

  Attributes:
    config_type: string, type of the configs, e.g. default, msan.
    constraints: string, additional toolchain constraints needed for the cpp
      toolchain definition. These must be valid targets in this repo or
      @bazel_tools.
      (Toolchain: https://docs.bazel.build/versions/master/toolchains.html)
  """

  # Currently supported config types.
  _SUPPORTED_CONFIG_TYPES = ["default", "msan"]

  # Map from the config type to additional pre-defined cpp toolchain
  # definition constraints.
  _TYPE_CONSTRAINTS_MAP = {
      "default": [],
      "msan": ["//constraints/sanitizers:support_msan"]
  }

  def __init__(self, root, config_type):
    """Inits Config.

    Args:
      root: string, absolute path to the bazel_{version} directory, e.g.
        /.../configs/ubuntu16_04_clang/1.0/bazel_0.15.0/.
      config_type: string, type of the configs.

    Returns:
      A Config object.
    Raises:
      ValueError: An error occurred when input config type is not supported.
    """

    # Validate config_type is supported.
    if config_type not in Config._SUPPORTED_CONFIG_TYPES:
      raise ValueError(
          "Input config type: %s is not supported. Supported types are %s" %
          (config_type, " ".join(Config._SUPPORTED_CONFIG_TYPES)))

    self._root = root
    self.config_type = config_type
    self.constraints = Config._TYPE_CONSTRAINTS_MAP[config_type]

  def get_config_dir(self):
    """Returns the absolute path of the cc toolchain configs directory."""
    return os.path.join(self._root, self.config_type)

  def get_metadata_path(self):
    """Returns the absolute path of the METADATA file."""
    return os.path.join(self.get_config_dir(), "METADATA")
