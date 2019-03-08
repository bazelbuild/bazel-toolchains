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
"""Module to exec cc toolchain targets and extract contents for all configs."""

from __future__ import print_function

import atexit
import os
import shlex
import shutil
import subprocess
import tarfile

from util import get_autoconfig_target_name
from util import get_git_root

GIT_ROOT = get_git_root()
CONFIG_REPO = "./local_config_cc"
CONFIG_FILES = ["cc_toolchain_config.bzl", "BUILD", "cc_wrapper.sh", "dummy_toolchain.bzl"]
TMP_DIR = os.path.join(GIT_ROOT, "release", "tmp")


def _cleanup():
  """Cleanup generated files."""
  if os.path.exists(TMP_DIR):
    shutil.rmtree(TMP_DIR)


def execute_and_extract_configs(container_configs_list, bazel_version,
                                buildifier):
  """Executes the docker_toolchain_autoconfig targets and extract configs.

  If configs already exist in this repo, the script will delete them and
  generate new ones.

  It generate cc configs which currently includes: CROSSTOOL, BUILD,
  cc_wrapper.sh and dummy_toolchain.bzl. Examples can be found in
  configs/ubuntu16_04_clang/1.0/bazel_0.15.0/default/.

  There is one such set of cc configs per container per Bazel version per config
  type.

  Args:
    container_configs_list: list of ContainerConfigs, the list of
      ContainerConfigs to generate configs for.
    bazel_version: string, the version of Bazel used to generate the configs.
  """

  atexit.register(_cleanup)

  # Create temporary directory to store generated tarballs of configs.
  if os.path.exists(TMP_DIR):
    shutil.rmtree(TMP_DIR)
  os.makedirs(TMP_DIR)

  for container_configs in container_configs_list:
    for config in container_configs.configs:

      # Get target basename from config definitions.
      target = get_autoconfig_target_name(
          config_type=config.config_type,
          distro=container_configs.distro,
          config_version=container_configs.version,
          bazel_version=bazel_version)

      # Remove old config dir if exists.
      if os.path.exists(config.get_config_dir()):
        print("\nOld version of toolchain configs for {target} already exists. "
              "Deleting and generating again.".format(target=target))
        shutil.rmtree(config.get_config_dir())

      # Generate config directory.
      os.makedirs(config.get_config_dir())

      command = ("bazel build //{PACKAGE}:{TARGET}").format(
          PACKAGE=container_configs.package, TARGET=target)
      print("\nExecuting command: %s\n" % command)
      subprocess.check_call(shlex.split(command))

      command = (
          "cp "
          "{GIT_ROOT}/bazel-out/k8-fastbuild/bin/{PACKAGE}/{TARGET}_outputs.tar"
          " {OUTPUT_DIR}/").format(
              GIT_ROOT=GIT_ROOT,
              OUTPUT_DIR=TMP_DIR,
              PACKAGE=container_configs.package,
              TARGET=target)
      print("\nExecuting command: %s\n" % command)
      subprocess.check_call(shlex.split(command))

      # Extract toolchain configs.
      tar_path = os.path.join(TMP_DIR, "%s_outputs.tar" % target)
      tar = tarfile.open(tar_path)

      for config_file in CONFIG_FILES:
        # Extract toolchain config without the CONFIG_REPO name.
        member = tar.getmember(os.path.join(CONFIG_REPO, config_file))
        member.name = os.path.basename(member.name)
        tar.extract(member, config.get_config_dir())
        if config_file == "BUILD" or config_file.endswith("bzl"):
          subprocess.check_call(
              shlex.split("%s --lint=fix %s" %
                          (buildifier,
                           os.path.join(config.get_config_dir(), config_file))))
