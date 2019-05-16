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

# This bash script provides an entry point for checks for
# rbe_autoconfig that use output_base and config_dir.
# It wraps around rbe_autoconf_checks in order
# to resolve the directory where files are to be checked.
# Usage: Use only from an sh_test target.
# First argument is the location of the AUTOCONF_ROOT file which
# has a single line with the absolute path to the root of the project.
# The second argument is the output_base declared in the rbe_autoconfig
# rule that is tested.
# Third argument is the config_dir declared in the rbe_autoconfig
# rule that is tested.
# The fourth argument is the Bazel version.
# All remaining args are interpreted as calls to functions in
# rbe_autoconf_checks.

set -e

AUTOCONF_ROOT=$1
OUTPUT_BASE=$2
CONFIG_DIR=$3
BAZEL_VERSION=$4

OUTPUT_BASE_EMPTY=$(cat ${AUTOCONF_ROOT})/${OUTPUT_BASE}/bazel_${BAZEL_VERSION}/CONFIG_DIR/empty
set -- ${OUTPUT_BASE_EMPTY} "${@:5}"
