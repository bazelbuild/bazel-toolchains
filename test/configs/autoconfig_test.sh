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

# Script to run the executable generated from a docker_toolchain_autoconfig rule
# and then check the toolchain configs for the c++ auto generated config exist.
#
# This script should be passed in 'srcs' of a sh_test test rule. The sh_test
# rule is expected to have the name {docker_toolchain_autoconfig_name}_test,
# where {docker_toolchain_autoconfig_name} is the docker_toolchain_autoconfig
# rule you would like to build and run.

set -e

# Define constants.
WORKSPACE_ROOT=$(pwd)
# The test name is hardcoded as {docker_toolchain_autoconfig_name}_test.
TARGET=${TEST_BINARY%_test}
NAME=${TARGET##*/}
DIR=${TARGET%${NAME}}
autoconfig_script=${WORKSPACE_ROOT}/${DIR}${NAME}

# Helper function for always delete the containers / temporary files on exit
function cleanup_on_finish {
  echo "=== Deleting images  ==="
  # Images to be removed are expected to have "rbe-test-" as name prefix.
  images=($(docker images -a | grep "rbe-test-" | awk '{print $3}'))
  for image in "${images[@]}"
  do
    echo "Attempting to delete ${image}..."
    # Only delete the image if it is not used by any running container.
    if [[ -z $(docker ps -q -f ancestor=${image}) ]]; then
      docker rmi -f ${image}
      echo "${image} deleted..."
    else
      echo "${image} is used by another container, not deleted..."
    fi
  done
  echo "Deleting all dangling images..."
  docker images -f "dangling=true" -q | xargs -r docker rmi -f
}

trap cleanup_on_finish EXIT # always delete the containers

# Change the output location to a tmp location inside the current Bazel workspace.
sed -i "s|/tmp|${TEST_TMPDIR}|g" ${autoconfig_script}

# Execute the autoconfig script and unpack toolchain config tarball.
${autoconfig_script}
tar -xf ${TEST_TMPDIR}/${NAME}.tar -C ${TEST_TMPDIR}

# Check existence of generated file.
file ${TEST_TMPDIR}/local_config_cc/CROSSTOOL
file ${TEST_TMPDIR}/local_config_cc/BUILD
file ${TEST_TMPDIR}/local_config_cc/cc_wrapper.sh
file ${TEST_TMPDIR}/local_config_cc/dummy_toolchain.bzl

echo "PASS"
