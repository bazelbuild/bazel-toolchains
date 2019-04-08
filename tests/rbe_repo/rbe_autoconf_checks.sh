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
  assert_file_exists ${DIR}/config/stub.BUILD
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

# Checks that java config files were generated
assert_java_confs() {
  assert_file_exists ${DIR}/java/stub.BUILD
}

# Checks that java config files were not generated
assert_no_java_confs() {
  assert_file_not_exists ${DIR}/java/stub.BUILD
}

# Checks that cc config files were generated
assert_cc_confs() {
  assert_file_exists ${DIR}/cc/stub.BUILD
  assert_file_exists ${DIR}/cc/cc_toolchain_config.bzl
  assert_file_exists ${DIR}/cc/dummy_toolchain.bzl
  assert_file_exists ${DIR}/cc/cc_wrapper.sh
}

# Checks that cc config files were generated
assert_checked_in_cc_confs() {
  assert_file_exists ${DIR}/cc/stub.BUILD
  assert_file_not_exists ${DIR}/cc/cc_toolchain_config.bzl
  assert_file_not_exists ${DIR}/cc/dummy_toolchain.bzl
  assert_file_not_exists ${DIR}/cc/cc_wrapper.sh
}

# Checks that cc config files were not generated
assert_no_cc_confs() {
  assert_file_not_exists ${DIR}/cc/stub.BUILD
  assert_file_not_exists ${DIR}/cc/cc_toolchain_config.bzl
  assert_file_not_exists ${DIR}/cc/dummy_toolchain.bzl
  assert_file_not_exists ${DIR}/cc/cc_wrapper.sh
}

EMPTY_FILE=$1
DIR=$(dirname "${EMPTY_FILE}")
for var in "$@"
do
  if [ "$var" != "$1" ]; then
    $var
  fi
done

