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

# Integration test to validate the docker_toolchain_autoconfig rule.
#
# This test validates the docker_toolchain_autoconfig rule. It generates
# toolchain configs for Bazel 0.7.0 release, and compares newly generated
# configs with verified ones.

set -e

# Define constants.
WORKSPACE_ROOT=$(pwd)
TEST_CONFIGS_DIR=${WORKSPACE_ROOT}/test/testdata/debian8_clang_test_configs
TEMP_DIR=${WORKSPACE_ROOT}/tmp

# Helper function for always deleting the containers / temporary files on exit
function cleanup_on_finish {
  echo -e "\n=== Cleaning up ==="
  echo "..................."
  rm -rf ${TEMP_DIR}
}

trap cleanup_on_finish EXIT # always delete the temporary files

# Create temporary directory.
mkdir ${TEMP_DIR}

autoconfig_script=${WORKSPACE_ROOT}/rules/debian8-clang-0.7.0-autoconfig

# Change the output location to a tmp location inside the current Bazel workspace.
sed -i "s|/tmp|${TEMP_DIR}|g" ${autoconfig_script}

# Execute the autoconfig script and unpack toolchain config tarball.
${autoconfig_script}
tar -xf ${TEMP_DIR}/debian8-clang-0.7.0-autoconfig.tar -C ${TEMP_DIR}

# Remove generated files that are not part of toolchain configs
rm -rf ${TEMP_DIR}/local_config_cc/tools ${TEMP_DIR}/local_config_cc/WORKSPACE

# Rename BUILD.test to BUILD in the verified configs for easy comparison.
mv ${TEST_CONFIGS_DIR}/BUILD.test ${TEST_CONFIGS_DIR}/BUILD

# Do not exit immediately if diff result is not empty.
set +e

# Compare the two directories.
diff_result=$(diff -ry --suppress-common-lines ${TEMP_DIR}/local_config_cc ${TEST_CONFIGS_DIR})
if [[ -n ${diff_result} ]]; then
  echo -e "Toolchain configs are changed.\n${diff_result}\n"
  exit -1
fi

echo "PASS"
