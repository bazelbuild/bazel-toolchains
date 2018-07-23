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
"""Script to generate cc toolchain configs."""

from __future__ import print_function

import argparse
import atexit
import imp
import os
import shlex
import shutil
from string import Template
import subprocess
import tarfile

from bazelrc import create_bazelrc_and_update_link
from toolchain_flags import update_toolchain_bazelrc_file
from config import ContainerConfigs
from util import get_date
from util import get_git_root

CONFIG_TYPES = ["default", "msan"]
CONFIG_REPO = "local_config_cc"
CONFIG_FILES = ["CROSSTOOL", "BUILD", "cc_wrapper.sh", "dummy_toolchain.bzl"]

BUILD_EXTRA_LICENCE = """
licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])
"""

# Define path constants.
GIT_ROOT = get_git_root()
SHA_MAP_FILE = os.path.join(GIT_ROOT, "rules/toolchain_containers.bzl")
WORK_DIR = os.path.join(GIT_ROOT, "release")
TMP_DIR = os.path.join(WORK_DIR, "tmp")
BAZELRC_DIR = os.path.join(GIT_ROOT, "bazelrc")
LATEST_BAZELRC_LINK = BAZELRC = os.path.join(BAZELRC_DIR, "latest.bazelrc")


def _get_tpl(name):
  """Get the absolute path to a template file.

  Args:
    name: string: the base name of the template file

  Returns:
    The absolute path of the template file.
  """
  return os.path.join(WORK_DIR, name)


def _get_container_configs_list(bazel_version):
  """Get the list of container configs to generate.

  Args:
    bazel_version: string, the version of Bazel used to generate configs.

  Returns:
    A list of ContainerConfigs objects corresponding to the configs to generate.
  """
  debian8_clang_configs = ContainerConfigs(
      distro="debian8",
      version="0.3.0",
      image="gcr.io/cloud-marketplace/google/clang-debian8",
      package="configs/debian8_clang",
      config_types=CONFIG_TYPES,
      platform_target="rbe_debian8",
      git_root=GIT_ROOT,
      bazel_version=bazel_version)

  ubuntu16_04_clang_configs = ContainerConfigs(
      distro="ubuntu16_04",
      version="1.0",
      image="gcr.io/cloud-marketplace/google/clang-ubuntu",
      package="configs/ubuntu16_04_clang",
      config_types=CONFIG_TYPES,
      platform_target="rbe_ubuntu1604",
      git_root=GIT_ROOT,
      bazel_version=bazel_version)

  return [debian8_clang_configs, ubuntu16_04_clang_configs]


def _generate_toolchain_definition(container_configs, bazel_version):
  """Generate new cpp toolchain definitions.

  Args:
    container_configs: ContainerConfigs, the ContainerConfigs to generate
      configs for.
    bazel_version: string, the version of Bazel used to generate the configs.

  Returns:
    None
  """
  cpp_dir = os.path.dirname(container_configs.get_cpp_build_path())

  # Remove old cpp directory if exists.
  if os.path.isdir(cpp_dir):
    shutil.rmtree(cpp_dir)
  os.makedirs(cpp_dir)

  with open(container_configs.get_cpp_build_path(), "w") as build_file:
    # Write license header.
    with open(_get_tpl("license.tpl"), "r") as license_header:
      build_file.write(license_header.read())

    # Write extra license string required for BUILD file.
    build_file.write(BUILD_EXTRA_LICENCE)

  for config in container_configs.configs:

    with open(container_configs.get_cpp_build_path(), "a") as build_file:
      with open(_get_tpl("cpp.tpl"), "r") as tpl_file:

        # Merge constraint lists. Remove duplicates while perserving order.
        constraints = container_configs.constraints
        for constraint in config.constraints:
          if constraint not in constraints:
            constraints.append(constraint)

        tpl = Template(tpl_file.read()).substitute(
            TYPE=config.config_type,
            CONFIG_VERSION=container_configs.version,
            BAZEL_VERSION=bazel_version,
            PACKAGE=container_configs.package,
            EXTRA_CONSTRAINTS="\n".join(
                [("\"%s\"," % constraint) for constraint in constraints]))

        build_file.write(tpl)

    subprocess.call(
        shlex.split("buildifier %s" % container_configs.get_cpp_build_path()))


def _create_target_if_not_exists(container_configs, config, bazel_version, sha,
                                 target, date):
  """Create the new docker_toolchain_autoconfig target if not exists.

  Args:
    container_configs: ContainerConfigs, the ContainerConfigs to generate
      configs for.
    config: Config, the Config to generate configs for.
    bazel_version: string, the version of Bazel used to generate the configs.
    sha: string, SHA256 of the container used to generate the configs.
    target: string, the base name of the docker_toolchain_autoconfig target.
    date: string, the date this script is executed.

  Returns:
    None
  """
  with open(container_configs.get_target_build_path(), "a+") as build_file:
    if target not in build_file.read():
      with open(_get_tpl("%s.tpl" % config.config_type), "r") as tpl_file:
        tpl = Template(tpl_file.read()).substitute(
            DATE=date,
            DISTRO=container_configs.distro,
            CONFIG_VERSION=container_configs.version,
            BAZEL_VERSION=bazel_version,
            NAME=container_configs.image,
            SHA=sha)

        build_file.write(tpl)


def _execute_and_extract_configs(container_configs, config, target):
  """Execute the docker_toolchain_autoconfig target and extract configs.

  If configs already exist in this repo, the script will delete them and
  generate new ones.

  Args:
    container_configs: ContainerConfigs, the ContainerConfigs to generate
      configs for.
    config: Config, the Config to generate configs for.
    target: string, the base name of the docker_toolchain_autoconfig target.

  Returns:
    None
  """

  # Remove old config dir if exists.
  if os.path.isdir(config.get_config_dir()):
    print("\nOld version of toolchain configs for {target} already exist. "
          "Deleting and generating again.".format(target=target))
    shutil.rmtree(config.get_config_dir())

  # Generate config directory.
  os.makedirs(config.get_config_dir())

  command = ("bazel run --define=DOCKER_AUTOCONF_OUTPUT={OUTPUT_DIR} "
             "//{PACKAGE}:{TARGET}").format(
                 OUTPUT_DIR=TMP_DIR,
                 PACKAGE=container_configs.package,
                 TARGET=target)
  print("\nExecuting command: %s\n" % command)
  subprocess.call(shlex.split(command))

  # Extract toolchain configs.
  tar_path = os.path.join(TMP_DIR, "%s.tar" % target)
  tar = tarfile.open(tar_path)

  for config_file in CONFIG_FILES:
    # Extract toolchain config without the CONFIG_REPO name.
    member = tar.getmember(os.path.join(CONFIG_REPO, config_file))
    member.name = os.path.basename(member.name)
    tar.extract(member, config.get_config_dir())


def _generate_metadata(container_configs, config, sha):
  with open(config.get_metadata_path(), "w") as metadata_file:
    metadata_file.write("{image}@{sha}\n".format(
        image=container_configs.image, sha=sha))


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
  return parser.parse_args()


def _cleanup():
  """Cleanup generated files."""
  shutil.rmtree(TMP_DIR)


def main(bazel_version, date):
  """Main function.

  Examples of usage:

    python release/config_release.py -b 0.15.0

  Args:
    bazel_version: string, the version of Bazel used to generate the configs.
    date: string, the date this script is executed.

  Returns:
    None
  """

  # Create temporary directory to store generated tarballs of configs.
  os.makedirs(TMP_DIR)

  # Get current supported list of container configs to generate.
  container_configs_list = _get_container_configs_list(bazel_version)

  container_sha_map = imp.load_source("toolchain_containers", SHA_MAP_FILE)

  for container_configs in container_configs_list:
    sha = container_sha_map.toolchain_container_sha256s()[
        "%s_clang" % container_configs.distro]

    for config in container_configs.configs:

      # Get target basename from config definitions.
      target = ("{type}-{distro}-clang-{config_version}-"
                "bazel_{bazel_version}-autoconfig").format(
                    type=config.config_type,
                    distro=container_configs.distro,
                    config_version=container_configs.version,
                    bazel_version=bazel_version)

      # Only create the new target in the BUILD file if it does not exist.
      _create_target_if_not_exists(container_configs, config, bazel_version,
                                   sha, target, date)

      # Execute the target and extract toolchain configs.
      #_execute_and_extract_configs(container_configs, config, target)

      # Generate METADATA file.
      #_generate_metadata(container_configs, config, sha)

    # Generate new cpp toolchain definition targets.
    _generate_toolchain_definition(container_configs, bazel_version)

    # Update toolchain.bazelrc file.
    update_toolchain_bazelrc_file(container_configs, bazel_version)

  # Create sample .bazelrc file
  create_bazelrc_and_update_link(bazel_version)


if __name__ == "__main__":

  atexit.register(_cleanup)
  args = _parse_arguments()
  main(args.bazel_version, get_date())
