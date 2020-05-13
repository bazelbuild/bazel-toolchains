#!/bin/bash
#
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

# This bash script defines common assertion functions for rbe_autoconfig
# file checks.
# Usage: Use only from an sh_test target.
# First argument is the location of the empty file in the test
# directory produced by rbe_autoconfig when create_testdata attr
# is used.
# All remaining args are interpreted as calls to functions in this
# file.

set -e

assert_file_not_exists() {
  FILE=$1
  if [ ! -f $FILE ]; then
    echo "File $FILE does not exist."
    echo "Passed"
  else
    echo "Failed: $FILE exists."
    exit 1
  fi
}

assert_file_exists() {
  FILE=$1
  if [ ! -f $FILE ]; then
    echo "File $FILE does not exist."
    exit 1
  else
    echo "Failed: $FILE exists."
    echo "Passed"
  fi
}

# Checks the config BUILD file was created
assert_basic_cofig() {
  assert_file_exists ${DIR}/config/test.BUILD
}

# Checks that files not needed when using checked-in
# configs are not generated
assert_checked_in_confs() {
  assert_file_not_exists ${DIR}/output.tar
  assert_file_not_exists ${DIR}/run_and_extract.sh
}

# Checks that files needed when creating configs
# were generated
assert_no_checked_in_confs() {
  assert_file_exists ${DIR}/output.tar
  assert_file_exists ${DIR}/run_and_extract.sh
  assert_file_exists ${DIR}/container/run_in_container.sh
}

# Checks the dummy file produced after image is pulled is present
assert_image_pulled() {
  assert_file_exists ${DIR}/image_name
}

# Checks the dummy file produced after image is pulled is not present
assert_image_not_pulled() {
  assert_file_not_exists ${DIR}/image_name
}

# Checks that java config files were generated
assert_java_confs() {
  assert_file_exists ${DIR}/java/test.BUILD
}

# Checks that java config files were not generated
assert_no_java_confs() {
  assert_file_not_exists ${DIR}/java/test.BUILD
}

# Checks that cc config files were generated
assert_cc_confs() {
  assert_file_exists ${DIR}/cc/test.BUILD
  assert_file_exists ${DIR}/cc/cc_toolchain_config.bzl
  assert_file_exists ${DIR}/cc/cc_wrapper.sh
}

# Checks that Windows cc config files were generated
assert_cc_confs_windows() {
  assert_file_exists ${DIR}/cc/test.BUILD
  assert_file_exists ${DIR}/cc/windows_cc_toolchain_config.bzl
}

# Checks that checked in configs were selected
assert_checked_in_cc_confs() {
  assert_file_exists ${DIR}/cc/test.BUILD
  assert_file_not_exists ${DIR}/cc/cc_toolchain_config.bzl
  assert_file_not_exists ${DIR}/cc/cc_wrapper.sh
}

# Checks that cc config files were not generated
assert_no_cc_confs() {
  assert_file_not_exists ${DIR}/cc/test.BUILD
  assert_file_not_exists ${DIR}/cc/cc_toolchain_config.bzl
  assert_file_not_exists ${DIR}/cc/cc_wrapper.sh
}

# Checks that java_home was read from container
assert_java_home() {
  assert_file_exists ${DIR}/get_java_home.sh
}

# Checks that java_home was not read from container
assert_no_java_home() {
  assert_file_not_exists ${DIR}/get_java_home.sh
}

# Checks that cc config files were generated in the output_base
assert_output_base_cc_confs() {
  assert_file_exists ${DIR}/cc/test.BUILD
  assert_file_exists ${DIR}/cc/cc_toolchain_config.bzl
  assert_file_exists ${DIR}/cc/cc_wrapper.sh
}

# Checks that Windows cc config files were generated in the output_base
assert_output_base_cc_confs_windows() {
  assert_file_exists ${DIR}/cc/test.BUILD
  assert_file_exists ${DIR}/cc/windows_cc_toolchain_config.bzl
}

# Checks that cc config files were not generated in the output_base
assert_output_base_no_cc_confs() {
  assert_file_not_exists ${DIR}/cc/test.BUILD
  assert_file_not_exists ${DIR}/cc/cc_toolchain_config.bzl
  assert_file_not_exists ${DIR}/cc/cc_wrapper.sh
}

# Checks that java config files were generated in the output_base
assert_output_base_java_confs() {
  assert_file_exists ${DIR}/java/test.BUILD
}

# Checks that java config files were not generated in the output_base
assert_output_base_no_java_confs() {
  assert_file_not_exists ${DIR}/java/test.BUILD
}

# Checks that platform config files + additional output files
# were generated in the output_base
assert_output_base_platform_confs() {
  assert_file_exists ${DIR}/config/test.BUILD
  assert_file_exists ${DIR}/../../.latest.bazelrc
  assert_file_exists ${DIR}/../../versions.bzl
}

# Checks that files for custom repos (bazel_skylib, local_config_sh)
# were generated in the output_base
assert_output_base_custom_confs() {
  assert_file_exists ${DIR}/local_config_sh/WORKSPACE
  assert_file_exists ${DIR}/local_config_sh/test.BUILD
}

# Checks that configs.tar file to export configs was generated in the remote repo
# when export_configs was NOT used
assert_configs_tar() {
  assert_file_exists ${DIR}/configs.tar
}

# Checks that configs.tar file to export configs was NOT generated in the remote repo
# when export_configs was used
assert_no_configs_tar() {
  assert_file_not_exists ${DIR}/configs.tar
}

EMPTY_FILE=$1
DIR=$(dirname "${EMPTY_FILE}")
for var in "$@"
do
  if [ "$var" != "$1" ]; then
    $var
  fi
done
