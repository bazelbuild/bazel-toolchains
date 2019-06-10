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

# This bash script runs a bazel build for rbe_autoconfig
# and extracts the produced tar file. Should only be used by
# rbe_custom_config_tar.yaml

set -ex

# Build @rbe_custom
bazel build @rbe_custom_config_tar//...

# Extract the produced configs.tar
mkdir ../config_out
tar -xf $(bazel info output_base)/external/rbe_custom_config_tar/configs.tar -C ../config_out
