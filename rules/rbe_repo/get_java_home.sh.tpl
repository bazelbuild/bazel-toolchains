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

# This is a generated file that gets the value of the JAVA_HOME env
# var in a docker image.

DOCKER="%{docker_tool_path}"

# Check docker tool is available
if [[ -z "${DOCKER}" ]]; then
    echo >&2 "error: docker not found; do you need to set DOCKER_PATH env var?"
    exit 1
fi

echo $(${DOCKER} inspect -f '{{range $i, $v := .Config.Env}}{{println $v}}{{end}}' %{image_name} | grep JAVA_HOME | cut -d'=' -f2)
