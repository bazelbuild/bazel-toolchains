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

# Script to copy a file/directory located inside a container as a tarball.
# Usage:
#   ./container_file_export.sh l.gcr.io/google/python:latest /opt/python3.6 py.tar.gz
# In order to use this script, you need to have docker installed, see
# https://docs.docker.com/engine/installation/
#
# Noted: this script is only meant to be used directly by the corresponding
#        container_file_export skylark rule.

#!/usr/bin/env bash

set -ex

main() {
  if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters: ./container_cp.sh <DOCKER_IMAGE> <SOURCE_PATH> <TARGET_TARALL_FILE>"
  fi

  IMAGE=$1
  SOURCE=$2
  TARGET=$3

  # On Bazel CI $RANDOM somehow doesn't work. Use another way for generating a random number
  # TODO: change back to use $RANDOM once it is available on Bazel CI.
  random_number=$(python -c "import random; print random.randint(1, 1024)")
  container_name="data-container-${random_number}"
  docker run -t -d --name ${container_name} $IMAGE sleep infinity
  docker exec -e GZIP=-n ${container_name} tar -czf /tmp/data.tar.gz --mtime='1970-01-01' $SOURCE
  docker cp ${container_name}:/tmp/data.tar.gz $TARGET
  docker rm -f ${container_name}
}

main $@
