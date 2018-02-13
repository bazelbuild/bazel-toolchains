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
# toolchain configs for Bazel 0.10.0 release, and compares newly generated
# configs with published ones.

set -e

# Define constants.
WORKSPACE_ROOT=$(pwd)
COMMIT=acffd62731b1545c32e1c34e72fd526598ab9a66
BAZEL_VERSION=0.10.0
TEST_CONFIGS_DIR=${TEST_TMPDIR}/bazel-toolchains-${COMMIT}/configs/debian8_clang/0.2.0/bazel_${BAZEL_VERSION}/
AUTOCONFIG_SCRIPT=${WORKSPACE_ROOT}/test/debian8-clang-0.2.0-bazel_${BAZEL_VERSION}-autoconfig-for-test

# Change the output location to a tmp location inside the current Bazel workspace.
sed -i "s|/tmp|${TEST_TMPDIR}|g" ${AUTOCONFIG_SCRIPT}

# Execute the autoconfig script and unpack toolchain config tarball.
${AUTOCONFIG_SCRIPT}
tar -xf ${TEST_TMPDIR}/debian8-clang-0.2.0-bazel_${BAZEL_VERSION}-autoconfig-for-test.tar -C ${TEST_TMPDIR}

# Remove generated files that are not part of toolchain configs
rm -rf ${TEST_TMPDIR}/local_config_cc/tools ${TEST_TMPDIR}/local_config_cc/WORKSPACE

# Unpack the tarball containing published toolchain configs for Bazel 0.10.0 from GitHub.
tar -xf ${TEST_SRCDIR}/bazel_toolchains_test/file/${COMMIT}.tar.gz -C ${TEST_TMPDIR}

# Remove METADATA file.
rm ${TEST_CONFIGS_DIR}/METADATA

# Do not exit immediately if diff result is not empty.
set +e

# Compare the two directories.
diff_result=$(diff -ry --suppress-common-lines ${TEST_TMPDIR}/local_config_cc ${TEST_CONFIGS_DIR})
if [[ -n ${diff_result} ]]; then
  echo -e "Toolchain configs are changed.\n${diff_result}\n"
  exit -1
fi

echo "PASS"
