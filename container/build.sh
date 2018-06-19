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

# TODO(xingao): Rewrite the script in Python or Go

# Map to store all supported container type and the package of target to build it.
declare -A TYPE_PACKAGE_MAP=(
  ["rbe-debian8"]="container/debian8/builders/rbe-debian8"
  ["rbe-debian9"]="container/experimental/rbe-debian9"
  ["rbe-ubuntu16_04"]="container/ubuntu16_04/builders/rbe-ubuntu16_04"
  ["ubuntu16_04-bazel"]="container/ubuntu16_04/builders/bazel"
  ["ubuntu16_04-bazel-docker"]="container/ubuntu16_04/builders/bazel"
)

# Map to store all supported container type and the name of target to build it.
declare -A TYPE_TARGET_MAP=(
  ["rbe-debian8"]="toolchain"
  ["rbe-debian9"]="toolchain"
  ["rbe-ubuntu16_04"]="toolchain"
  ["ubuntu16_04-bazel"]="bazel"
  ["ubuntu16_04-bazel-docker"]="bazel_docker"
)

# Map to store all supported container type and the name of target to build it.
declare -A TYPE_TARBALL_MAP=(
  ["rbe-debian8"]="toolchain-packages.tar"
  ["rbe-debian9"]="toolchain-packages.tar"
  ["rbe-ubuntu16_04"]="toolchain-packages.tar"
  ["ubuntu16_04-bazel"]="bazel-packages.tar"
  ["ubuntu16_04-bazel-docker"]="bazel_docker-packages.tar"
)

show_usage () {
  usage=$(cat << EOF

Usage: build.sh [options]

Builds the fully-loaded container, with Google Cloud Container Builder or locally.

Required parameters (when build with Google Cloud Container Builder):
    -d|--type               Type of the container: see TYPE_TARGET_MAP
    -p|--project            GCP project ID
    -c|--container          Docker container name
    -t|--tag                Docker tag for the image

Optional parameters (when build with Google Cloud Container Builder):
    -a|--async              asynchronous execute Cloud Container Builder
    -b|--bucket             GCS bucket to store the tarball of debian packages

Standalone parameters
    -l|--local              build container locally

To build with Google Cloud Container Builder:
$ ./build.sh -p my-gcp-project -d {container_type} \
    -c {container_name} -t latest -b my_bucket
will produce docker images in Google Container Registry:
    gcr.io/my-gcp-project/{container_type}:latest
and the debian packages installed will be packed as a tarball and stored in
gs://my_bucket for future reference, if -b is specified.

To build locally:
$ ./build.sh -d {container_type} -l
will produce docker locally as {container_type}:latest
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
      -d|--type)
        shift
        TYPE=$1
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
      -b|--bucket)
        shift
        BUCKET=$1
        shift
        ;;
      -a|--async)
        ASYNC=" --async "
        shift
        ;;
      -l|--local)
        LOCAL=true
        shift
        ;;
      *)
        echo "Unknown argument $1"
        show_usage
        exit 1
        ;;
    esac
  done

  if [[ ("$PROJECT" == "" || "$CONTAINER" == "" || "$TYPE" == "" || "$TAG" == "") && "$LOCAL" == "" ]]; then
     echo "Please specify all required options for building in Google Cloud Container Builder"
     show_usage
     exit 1
  fi

  if [[ -z ${TYPE_TARGET_MAP[$TYPE]} ]]; then
    echo "Type parameter can only be the following:"
    for type in "${!TYPE_TARGET_MAP[@]}"; do echo "$type"; done
    show_usage
    exit 1
  fi
}

main () {
  parse_parameters $@

  PROJECT_ROOT=$(git rev-parse --show-toplevel)
  PACKAGE=${TYPE_PACKAGE_MAP[$TYPE]}
  TARGET=${TYPE_TARGET_MAP[$TYPE]}
  TARBALL=${TYPE_TARBALL_MAP[$TYPE]}

  # We need to start the build from the root of the project, so that we can
  # mount the full root directory (to use bazel builder properly).
  cd ${PROJECT_ROOT}
  # We need to run clean to make sure we don't mount local build outputs
  bazel clean

  if [[ "$LOCAL" = true ]]; then
    echo "Building container locally."
    bazel run //${PACKAGE}:${TARGET}
    echo "Testing container locally."
    bazel test //${PACKAGE}:${TARGET}-test
    echo "Tagging container."
    docker tag bazel/${PACKAGE}:${TARGET} ${TYPE}:latest
    echo -e "\n" \
      "${TYPE}:lastest container is now available to use.\n" \
      "To try it: docker run -it ${TYPE}:latest \n"
  else
    echo "Building container in Google Cloud Container Builder."
    # Setup GCP project id for the build
    gcloud config set project ${PROJECT}
    # Ensure all BUILD files under /third_party have the right permission.
    # This is because in some systems the BUILD files under /third_party (after git clone)
    # will be with permission 640 and the build will fail in Container Builder.
    find ${PROJECT_ROOT}/third_party -type f -print0 | xargs -0 chmod 644

    config_file=${PROJECT_ROOT}/container/cloudbuild.yaml
    extra_substitution=",_BUCKET=${BUCKET},_TARBALL=${TARBALL}"
    if [[ "$BUCKET" == "" ]]; then
      config_file=${PROJECT_ROOT}/container/cloudbuild_no_bucket.yaml
      extra_substitution=""
    fi

    gcloud container builds submit . \
      --config=${config_file} \
      --substitutions _PROJECT=${PROJECT},_CONTAINER=${CONTAINER},_TAG=${TAG},_PACKAGE=${PACKAGE},_TARGET=${TARGET}${extra_substitution} \
      --machine-type=n1-highcpu-32 \
      ${ASYNC}

  fi
}

main $@
