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

set -ex

# This is a generated file that runs a docker container, waits for it to
# finish running and copies a file to an output location.

DOCKER="%{docker_tool_path}"

# Check docker tool is available
if [[ -z "${DOCKER}" ]]; then
    echo >&2 "error: docker not found; do you need to set DOCKER_PATH env var?"
    exit 1
fi

# In system where bind mounting is not supported/allowed, we need to copy the
# scripts and project source code used for Bazel autoconfig to the container.
%{copy_data_cmd}

# Pass an empty entrypoint to override any set by default in the container.
id=$("${DOCKER}" run -d --entrypoint "" %{docker_run_flags} %{image_name} %{commands})

"${DOCKER}" wait $id
# Check the docker logs contain the expected 'created outputs_tar' string
if "${DOCKER}" logs $id | grep -q 'created outputs_tar'; then
   echo "Successfully created outputs_tar"
else
   echo "Could not create outputs_tar, see docker log for details:"
   echo $("${DOCKER}" logs $id)
   exit 1
fi
"${DOCKER}" cp $id:%{extract_file} %{output}
"${DOCKER}" rm $id

# If a data volumn is created, delete it at the end.
%{clean_data_volume_cmd}
