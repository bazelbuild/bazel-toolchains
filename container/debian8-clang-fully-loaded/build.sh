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

#!/usr/bin/env bash
set -e


show_usage () {
  usage=$(cat << EOF
Usage: build.sh [options]

Builds the fully-loaded container using Google Cloud Container Builder.

Required options:
    -p|--project            GCP project ID
    -c|--container          docker container name
    -t|--tag                docker tag for the image

Optional options:
    -a|--async              asynchronous execute Cloud Container Builder

For example, running:
$ build.sh -p my-gcp-project -c debian8-clang-fully-loaded -t latest
will produce docker images:
    gcr.io/my-gcp-project/debian8-clang-fully-loaded:{latest, clang_revision}
EOF
)
  echo "$usage"
}


parse_parameters () {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_usage
        exit 0
        ;;
      -p|--project)
        shift
        PROJECT=$1
        shift
        ;;
      -c|--container)
        shift
        CONTAINER=$1
        shift
        ;;
      -t|--docker-tag)
        shift
        TAG=$1
        shift
        ;;
      -a|--async)
        ASYNC=" --async "
        shift
        ;;
      *)
        echo "Unknown argument $1"
        show_usage
        exit 1
        ;;
    esac
  done

  if [[ "$PROJECT" == "" || "$CONTAINER" == "" || "$TAG" == "" ]]; then
     echo "Please specify all required options"
     show_usage
     exit 1
  fi
}

main () {
  parse_parameters $@

  # Setup GCP project id for the build
  gcloud config set project ${PROJECT}

  PROJECT_ROOT=$(git rev-parse --show-toplevel)
  DIR="container/debian8-clang-fully-loaded"

  # We need to start the build from the root of the project, so that we can
  # mount the full root directory (to use bazel builder properly).
  cd ${PROJECT_ROOT}
  # We need to run clean to make sure we don't mount local build outputs
  bazel clean --async
  # Start Google Cloud Container Builder
  gcloud container builds submit . \
  --config=${PROJECT_ROOT}/container/debian8-clang-fully-loaded/cloudbuild.yaml \
  --substitutions _PROJECT=${PROJECT},_CONTAINER=${CONTAINER},_TAG=${TAG},_DIR=${DIR} \
  ${ASYNC}
}

main $@
