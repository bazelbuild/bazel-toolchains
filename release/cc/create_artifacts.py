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
"""Module to add METADATA and cc toolchain targets to BUILD for all configs."""

import imp
import os
import shlex
import shutil
from string import Template
import subprocess

from util import get_autoconfig_target_name
from util import get_date
from util import get_git_root

BUILD_EXTRA_LICENCE = """
licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])
"""

GIT_ROOT = get_git_root()
LICENCE_TPL = os.path.join(GIT_ROOT, "release", "license.tpl")
CPP_TPL = os.path.join(GIT_ROOT, "release", "cc", "cpp.tpl")
LATEST_TPL = os.path.join(GIT_ROOT, "release", "cc", "latest.tpl")
SHA_MAP_FILE = os.path.join(GIT_ROOT, "rules/toolchain_containers.bzl")
CLANG_REVISION_FILE = os.path.join(GIT_ROOT, "third_party/clang/revision.bzl")


def create_targets(container_configs_list, bazel_version):
  """Creates the new docker_toolchain_autoconfig target if not exists.

  An example target located in configs/ubuntu16_04_clang/BUILD is:
  //configs/ubuntu16_04_clang:msan-ubuntu16_04-clang-1.0-bazel_0.15.0-autoconfig

  There is one target per container per Bazel version per config type.

  The script only creates new targets in the BUILD file if they do not exist,
  i.e. if a target for the given version of Bazel, type and config version
  already exists, then the script does not re-create it.

  Args:
    container_configs_list: list of ContainerConfigs, the list of
      ContainerConfigs to generate configs for.
    bazel_version: string, the version of Bazel used to generate the configs.
  """

  container_sha_map = imp.load_source("toolchain_containers", SHA_MAP_FILE)
  clang_revision_map = imp.load_source("clang_revision", CLANG_REVISION_FILE)
  clang_revision = clang_revision_map.CLANG_REVISION

  for container_configs in container_configs_list:

    # Get the sha256 value of the container used to generate the configs.
    sha = container_sha_map.toolchain_container_sha256s()[
        "%s_clang" % container_configs.distro]

    for config in container_configs.configs:

      # Get target basename from config definitions.
      target = get_autoconfig_target_name(
          config_type=config.config_type,
          distro=container_configs.distro,
          config_version=container_configs.version,
          bazel_version=bazel_version)

      with open(container_configs.get_target_build_path(), "a+") as build_file:
        if target not in build_file.read():
          tpl_file_path = os.path.join(GIT_ROOT, "release", "cc",
                                       "%s.tpl" % config.config_type)
          with open(tpl_file_path, "r") as tpl_file:
            tpl = Template(tpl_file.read()).substitute(
                DATE=get_date(),
                DISTRO=container_configs.distro,
                CONFIG_VERSION=container_configs.version,
                BAZEL_VERSION=bazel_version,
                NAME=container_configs.image,
                SHA=sha,
                CLANG_REVISION=clang_revision)

            build_file.write(tpl)


def update_latest_target_aliases(container_configs_list, bazel_version,
                                 buildifier):
  """Updates the alias targets pointing to latest toolchain targets.

  Example latest aliases clang-ubuntu container are located in
  configs/ubuntu16_04_clang/latest/BUILD.

  There is one BUILD file to contain all aliases for a container_config.

  Args:
    container_configs_list: list of ContainerConfigs, the list of
      ContainerConfigs to generate configs for.
    bazel_version: string, the version of Bazel used to generate the configs.
  """

  for container_configs in container_configs_list:

    constraints = list(container_configs.constraints)

    with open(container_configs.get_latest_aliases_build_path(),
              "w") as build_file:
      # Update the BUILD file with aliases for latest toolchain targets.
      with open(LATEST_TPL, "r") as tpl_file:
        tpl = Template(tpl_file.read()).substitute(
            CONFIG_VERSION=container_configs.version,
            BAZEL_VERSION=bazel_version,
            PACKAGE=container_configs.package,
            PLATFORM=container_configs.platform_target,
            CONFIG_TYPES=", ".join(
                [("\"%s\"" % config_type)
                 for config_type in container_configs.config_types]),
            EXTRA_CONSTRAINTS="\n".join(
                [("\"%s\"," % constraint) for constraint in constraints]))

        build_file.write(tpl)

    subprocess.check_call(
        shlex.split(
            "%s --lint=fix %s" %
            (buildifier, container_configs.get_latest_aliases_build_path())))


def generate_toolchain_definition(container_configs_list, bazel_version,
                                  buildifier):
  """Generates new cpp toolchain definitions.

  Example cpp toolchain definitions for clang-ubuntu container are located in
  configs/ubuntu16_04_clang/1.0/bazel_0.15.0/cpp/.

  There is one BUILD file to contain all cpp toolchain definitions for each
  config type (e.g. default, msan) per container per Bazel version.

  If the file already exists in this repo, the script will delete it and
  generate new one.

  Args:
    container_configs_list: list of ContainerConfigs, the list of
      ContainerConfigs to generate configs for.
    bazel_version: string, the version of Bazel used to generate the configs.
  """

  for container_configs in container_configs_list:

    cpp_dir = os.path.dirname(container_configs.get_cpp_build_path())

    # Remove old cpp directory if exists.
    if os.path.exists(cpp_dir):
      print("\nOld version of cpp toolchain definition already exists. "
            "Deleting and generating again.")
      shutil.rmtree(cpp_dir)
    os.makedirs(cpp_dir)

    with open(container_configs.get_cpp_build_path(), "w") as build_file:
      # Write license header.
      with open(LICENCE_TPL, "r") as license_header:
        build_file.write(license_header.read())

      # Write extra license string required for BUILD file.
      build_file.write(BUILD_EXTRA_LICENCE)

    for config in container_configs.configs:

      with open(container_configs.get_cpp_build_path(), "a") as build_file:
        with open(CPP_TPL, "r") as tpl_file:

          # Merge constraint lists. Remove duplicates while perserving order.
          constraints = list(container_configs.constraints)
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

      subprocess.check_call(
          shlex.split("%s --lint=fix %s" %
                      (buildifier, container_configs.get_cpp_build_path())))


def generate_metadata(container_configs_list):
  """Creates the METADATA file with the container register path.

  Example METADATA file can be found at
  configs/ubuntu16_04_clang/1.0/bazel_0.15.0/default/METADATA.

  There is one METADATA file per container per Bazel version per config type.

  If the file already exists in this repo, the script will delete it and
  generate new one.

  Args:
    container_configs_list: list of ContainerConfigs, the list of
      ContainerConfigs to generate configs for.
  """

  container_sha_map = imp.load_source("toolchain_containers", SHA_MAP_FILE)

  for container_configs in container_configs_list:
    # Get the sha256 value of the container used to generate the configs.
    sha = container_sha_map.toolchain_container_sha256s()[
        "%s_clang" % container_configs.distro]

    for config in container_configs.configs:
      with open(config.get_metadata_path(), "w") as metadata_file:
        metadata_file.write("{image}@{sha}\n".format(
            image=container_configs.image, sha=sha))
