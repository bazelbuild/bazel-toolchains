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
"""A set of utility functions."""

import datetime
import subprocess


def get_git_root():
  """Returns the root directory of current git repository."""
  return subprocess.check_output(["git", "rev-parse",
                                  "--show-toplevel"]).strip()


def get_date():
  """Returns the current date in YYYY.MM.DD format."""
  now = datetime.datetime.now()
  return "%s.%s.%s" % (now.year, now.month, now.day)


def get_autoconfig_target_name(config_type, distro, config_version,
                               bazel_version):
  """Generates the docker_toolchain_autoconfig target name.

  Args:
    config_type: string, the type of the configs, e.g. default, msan.
    distro: string, base distro of container used to generate configs.
    config_version: string, the version of the configs.
    bazel_version: string, the version of Bazel used to generate the configs.

  Returns:
    The docker_toolchain_autoconfig target to generate the configs.
  """

  return ("{type}-{distro}-clang-{config_version}-"
          "bazel_{bazel_version}-autoconfig").format(
              type=config_type,
              distro=distro,
              config_version=config_version,
              bazel_version=bazel_version)
