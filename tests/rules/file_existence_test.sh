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

if [ -e $1 ]; then
  echo "Verified $1 exists"
else
  echo "$1 did not exist" && false
fi
