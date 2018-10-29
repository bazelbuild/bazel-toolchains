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
"""Module to create or update sample toolchain.bazelrc file."""

import os
from string import Template

from util import get_git_root

TPL = os.path.join(get_git_root(), "release", "toolchain.bazelrc.tpl")


def update_toolchain_bazelrc_file(container_configs_list, bazel_version):
  """Creates/updates toolchain.bazelrc file.

  Example toolchain.bazelrc file can be found at
  configs/ubuntu16_04_clang/1.0/toolchain.bazelrc.

  There is one toolchain.bazelrc file per container per config version.

  If the file already exists in this repo, the script will delete it and
  generate new one.

  Args:
    container_configs_list: list of ContainerConfigs, the list of
      ContainerConfigs to generate configs for.
    bazel_version: string, the version of Bazel used to generate the configs.
  """

  for container_configs in container_configs_list:
    with open(container_configs.get_toolchain_bazelrc_path(),
              "w") as toolchain_bazelrc_file:
      # Create or update toolchain.bazelrc file.
      with open(TPL, "r") as tpl_file:
        tpl = Template(tpl_file.read()).substitute(
            CONFIG_VERSION=container_configs.version,
            BAZEL_VERSION=bazel_version,
            PACKAGE=container_configs.package,
            PLATFORM=container_configs.platform_target,
        )

        toolchain_bazelrc_file.write(tpl)
