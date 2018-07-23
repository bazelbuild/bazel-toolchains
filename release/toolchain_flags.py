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

GIT_ROOT = get_git_root()
WORK_DIR = os.path.join(GIT_ROOT, "release")
TPL = os.path.join(WORK_DIR, "toolchain.bazelrc.tpl")


def update_toolchain_bazelrc_file(container_configs, bazel_version):
  """Create/update toolchain.bazelrc file.

  Args:
    container_configs: ContainerConfigs, the ContainerConfigs to generate
      configs for.
    bazel_version: string, the version of Bazel used to generate the configs.

  Returns:
    None
  """
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
