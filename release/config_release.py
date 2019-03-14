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
"""Script to generate toolchain configs for all config types and containers."""

from __future__ import print_function

import argparse
import sys

# Do not generate .pyc files.
sys.dont_write_bytecode = True

import bazelrc
import cc.create_artifacts as cc_create
import cc.execute_targets as cc_execute
from config import ContainerConfigs
import toolchain_flags
from util import get_git_root

CONFIG_TYPES = ["default", "msan"]

# Define path constants.
GIT_ROOT = get_git_root()


def _get_container_configs_list(bazel_version):
  """Gets the list of container configs to generate.

  Args:
    bazel_version: string, the version of Bazel used to generate configs.

  Returns:
    A list of ContainerConfigs objects corresponding to the configs to generate.
  """

  ubuntu16_04_clang_configs = ContainerConfigs(
      distro="ubuntu16_04",
      version="1.2",
      image="marketplace.gcr.io/google/clang-ubuntu",
      package="configs/ubuntu16_04_clang",
      config_types=CONFIG_TYPES,
      platform_target="rbe_ubuntu1604",
      git_root=GIT_ROOT,
      bazel_version=bazel_version)

  return [ubuntu16_04_clang_configs]


def _parse_arguments():
  """Parses command line arguments for the script.

  Returns:
    args object containing the arguments
  """
  parser = argparse.ArgumentParser()
  parser.add_argument(
      "-b",
      "--bazel_version",
      required=True,
      help="the version of Bazel used to generate toolchain configs")
  parser.add_argument(
      "-l",
      "--buildifier",
      default="/usr/bin/buildifier",
      help="the full path of buildifier used to format toolchain configs")
  return parser.parse_args()


def main(bazel_version, buildifier):
  """Main function.

  Examples of usage:
    python release/config_release.py -b 0.15.0

  Args:
    bazel_version: string, the version of Bazel used to generate the configs.
  """

  # Get current supported list of container configs to generate.
  container_configs_list = _get_container_configs_list(bazel_version)

  # Only create the new target in the BUILD file if it does not exist.
  cc_create.create_targets(container_configs_list, bazel_version)

  # Execute the target and extract toolchain configs.
  cc_execute.execute_and_extract_configs(container_configs_list, bazel_version,
                                         buildifier)

  # Generate METADATA file.
  cc_create.generate_metadata(container_configs_list)

  # Generate new cpp toolchain definition targets.
  cc_create.generate_toolchain_definition(container_configs_list, bazel_version,
                                          buildifier)

  # Update aliases to latest toolchain configs.
  cc_create.update_latest_target_aliases(container_configs_list, bazel_version,
                                         buildifier)

  # Update toolchain.bazelrc file.
  toolchain_flags.update_toolchain_bazelrc_file(container_configs_list,
                                                bazel_version)

  # Create sample .bazelrc file and update latest.bazelrc symlink.
  bazelrc.create_bazelrc_and_update_link(bazel_version)


if __name__ == "__main__":

  args = _parse_arguments()
  main(args.bazel_version, args.buildifier)
