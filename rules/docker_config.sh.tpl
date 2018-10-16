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

#!/bin/bash
# Main script for the docker_autoconfigure rule.
# Loads a container, runs it, copies outputs to tar file.
set -ex

main() {
  export PYTHON_RUNFILES=$(pwd)/../
  trap cleanup_on_finish EXIT # always cleanup
  # Expand a tar file with the repo if needed
  %{EXPAND_REPO_CMD}
  # Load the image from the tar file
  docker load -i %{INPUT_IMAGE_TAR}
  # Run the container image to build the config repos
  docker run --rm -e USER_ID="$(id -u)" -v $(pwd):/bazel-config -i %{IMAGE_NAME}
  # Delete the loaded image
  if [[ -z $(docker ps -q -f ancestor=%{IMAGE_NAME}) ]]; then
      docker rmi -f %{IMAGE_NAME} | true
      echo "%{IMAGE_NAME} deleted..."
  fi
  # Create a tar file with all the config repos that were built
  tar -cf outputs.tar %{CONFIG_REPOS}
  # Copy the tar file to its desired output location
  cp outputs.tar %{OUTPUT}
}

cleanup_on_finish() {
  # Remove the expanded repo if needed
  %{RM_REPO_CMD}
  # Remove the produced tar file
  rm outputs.tar
}

main $@
