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

# Test each language layer and the fully-loaded container can be fully
# reproduced from our saved tar of debian packages.

set -e

function print_usage {
    echo "Usage:"
    echo "  -c name of the container"
    echo "  -s value of the expected sha to check against"
    if [[ -n $1 ]]; then
      echo $1
    fi
    exit 1
}

# Define constants.
WORKSPACE_ROOT=$(pwd)
NAME=${TEST_BINARY##*/}
DIR=${TEST_BINARY%${NAME}}

container=""
valid_sha=""

OPTIND=1 # Reset for getopts, just in case.
  while getopts "c:s:" opt; do
    case "$opt" in
      c)
        [[ -z "$container" ]] || print_usage "ERROR: Flag specified twice"
        container=$OPTARG
        ;;
      s)
        [[ -z "$valid_sha" ]] || print_usage "ERROR: Flag specified twice"
        valid_sha=$OPTARG
        ;;
      *)
        print_usage "ERROR: unknown option"
        ;;
    esac
  done

[[ "$container" != "" ]] || print_usage "ERROR: must specify the container name"
[[ "$valid_sha" != "" ]] || print_usage "ERROR: must specify the value of valid valid_sha"

# Execute the script to build the container.
${WORKSPACE_ROOT}/${DIR}${container}
current_sha=$(docker inspect --format="{{.Id}}" bazel/${DIR%/}:${container})

if [ "${current_sha}" != "${valid_sha}" ]; then
  echo "Image valid_sha of bazel/${DIR%/}:${container} is changed."
  exit -1
fi

echo "PASS"

# TODO(xingao): clean up test images when test finishes.
