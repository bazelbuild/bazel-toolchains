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

set -ex

# Define constants.
WORKSPACE_ROOT=$(pwd)
COMMIT=cddc376d428ada2927ad359211c3e356bd9c9fbb
BAZEL_VERSION=0.24.0
CONFIG_VERSION=1.2
TEST_CONFIGS_DIR=${TEST_TMPDIR}/bazel-toolchains-${COMMIT}/configs/ubuntu16_04_clang/${CONFIG_VERSION}/bazel_${BAZEL_VERSION}/default/
AUTOCONFIG_SCRIPT=${WORKSPACE_ROOT}/tests/config/ubuntu16_04-clang-${CONFIG_VERSION}-bazel_${BAZEL_VERSION}-autoconfig

# Execute the autoconfig script and unpack toolchain config tarball.
tar -xf ${AUTOCONFIG_SCRIPT}_outputs.tar -C ${TEST_TMPDIR}

# Remove generated files that are not part of toolchain configs
rm -rf ${TEST_TMPDIR}/local_config_cc/tools ${TEST_TMPDIR}/local_config_cc/WORKSPACE
BUILDIFIER_VERSION=0.22.0
wget -q https://github.com/bazelbuild/buildtools/releases/download/${BUILDIFIER_VERSION}/buildifier
chmod +x ./buildifier
./buildifier --lint=fix ${TEST_TMPDIR}/local_config_cc/BUILD
./buildifier --lint=fix ${TEST_TMPDIR}/local_config_cc/cc_toolchain_config.bzl

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
