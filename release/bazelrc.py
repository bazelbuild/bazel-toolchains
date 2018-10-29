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
"""Module to generate sample bazelrc file."""

import os
from string import Template

from util import get_git_root

GIT_ROOT = get_git_root()
BAZELRC_DIR = os.path.join(GIT_ROOT, "bazelrc")
LATEST_BAZELRC_LINK = BAZELRC = os.path.join(BAZELRC_DIR, "latest.bazelrc")
LICENCE_TPL = os.path.join(GIT_ROOT, "release", "license.tpl")
BAZELRC_TPL = os.path.join(GIT_ROOT, "release", "bazelrc.tpl")


def create_bazelrc_and_update_link(bazel_version):
  """Creates new sample .bazelrc file and update latest.bazelrc symlink.

  Example bazelrc files can be found in directory bazelrc/.

  There is one sample bazelrc file Bazel version. bazelrc/latest.bazelrc should
  always be symlinked to the .bazelrc file for the latest version of Bazel.

  If the file already exists in this repo, the script will delete it and
  generate new one.

  Args:
    bazel_version: string, the version of Bazel used to generate the configs.
  """
  bazelrc_path = os.path.join(
      BAZELRC_DIR, "bazel-{version}.bazelrc".format(version=bazel_version))

  # Remove old version of this .bazelrc file.
  if os.path.exists(bazelrc_path):
    os.remove(bazelrc_path)

  with open(bazelrc_path, "w") as bazelrc_file:
    # Write license header.
    with open(LICENCE_TPL, "r") as license_header:
      bazelrc_file.write(license_header.read())

    # Write sample .bazelrc body.
    with open(BAZELRC_TPL, "r") as tpl_file:
      tpl = Template(tpl_file.read()).substitute(BAZEL_VERSION=bazel_version)
      bazelrc_file.write(tpl)

  # Update latest.bazelrc link
  if os.path.exists(LATEST_BAZELRC_LINK):
    os.remove(LATEST_BAZELRC_LINK)
  os.symlink(os.path.basename(bazelrc_path), LATEST_BAZELRC_LINK)
