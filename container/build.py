#!/usr/bin/env python

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

"""Builds a toolchain container, with Google Cloud Container Builder or locally.

To build with Google Cloud Container Builder:
$ python build.py -p my-gcp-project -d {container_type} -c {container_name} -t latest -b my_bucket
will produce docker images in Google Container Registry:
    gcr.io/my-gcp-project/{container_type}:latest
and the debian packages installed will be packed as a tarball and stored in
gs://my_bucket for future reference, if -b is specified.
To build locally:
$ python build.py -d {container_type} -l
will produce docker locally as {container_type}:latest

usage:
  build.py -d {rbe-debian8,rbe-debian9,rbe-ubuntu16_04,ubuntu16_04-bazel-docker,ubuntu16_04-bazel}
      [-p PROJECT] [-c CONTAINER] [-t TAG] [-a] [-b BUCKET] [-h]
      [-l]

required arguments:
  -d TYPE, --type TYPE  Type of the container: see TYPE_TARGET_MAP
  -p PROJECT, --project PROJECT
                        GCP project ID
  -c CONTAINER, --container CONTAINER
                        Docker container name
  -t TAG, --tag TAG     Docker tag for the image

optional arguments:
  -a, --async           Asynchronous execute Cloud Container Builder
  -b BUCKET, --bucket BUCKET
                        GCS bucket to store the tarball of debian packages
  -h, --help            print this help text and exit

standalone arguments:
  -l, --local           Build container locally
"""

from __future__ import print_function
import argparse
import os
import shlex
import subprocess
import sys

LATEST_BAZEL_VERSION = "0.15.0"

supported_types = [
                    "rbe-debian8", 
                    "rbe-debian9",
                    "rbe-ubuntu16_04",
                    "ubuntu16_04-bazel",
                    "ubuntu16_04-bazel-docker"
                  ]

# Map to store all supported container type and
# the package of target to build it.
TYPE_PACKAGE_MAP = {
    "rbe-debian8": "container/debian8/builders/rbe-debian8",
    "rbe-debian9": "container/experimental/rbe-debian9",
    "rbe-ubuntu16_04": "container/ubuntu16_04/builders/rbe-ubuntu16_04",
    "ubuntu16_04-bazel": "container/ubuntu16_04/builders/bazel",
    "ubuntu16_04-bazel-docker": "container/ubuntu16_04/builders/bazel",
}

# Map to store all supported container type and the name of target to build it.
TYPE_TARGET_MAP = {
    "rbe-debian8": "toolchain",
    "rbe-debian9": "toolchain",
    "rbe-ubuntu16_04": "toolchain",
    "ubuntu16_04-bazel": "bazel_{}".format(LATEST_BAZEL_VERSION),
    "ubuntu16_04-bazel-docker": "bazel_{}_docker".format(LATEST_BAZEL_VERSION),
}

# Map to store all supported container type and the name of target to build it.
TYPE_TARBALL_MAP = {
    "rbe-debian8":
        "toolchain-packages.tar",
    "rbe-debian9":
        "toolchain-packages.tar",
    "rbe-ubuntu16_04":
        "toolchain-packages.tar",
    "ubuntu16_04-bazel":
        "bazel_{}-packages.tar".format(LATEST_BAZEL_VERSION),
    "ubuntu16_04-bazel-docker":
        "bazel_{}_docker-packages.tar".format(LATEST_BAZEL_VERSION),
}

assert set(supported_types) \
        == set(TYPE_PACKAGE_MAP.keys()) \
        == set(TYPE_TARGET_MAP.keys()) \
        == set(TYPE_TARBALL_MAP.keys()), \
            "TYPES ARE OUT OF SYNC"


def main(type_, project, container, tag, async_, bucket, local):
  '''Runs the build. More info in module docstring at the top.
  '''
  project_root = subprocess.check_output(
      shlex.split("git rev-parse --show-toplevel")).strip()
  package = TYPE_PACKAGE_MAP[type_]
  target = TYPE_TARGET_MAP[type_]
  tarball = TYPE_TARBALL_MAP[type_]

  # We need to start the build from the root of the project, so that we can
  # mount the full root directory (to use bazel builder properly).
  os.chdir(project_root)
  # We need to run clean to make sure we don't mount local build outputs
  subprocess.call(["bazel", "clean"])

  if local:
    local_build(type_, package, target)
  else:
    cloud_build(project_root, project, container, tag, async_, bucket, package, target, tarball)

def local_build(type_, package, target):
  '''Runs the build locally. More info in module docstring at the top.
  '''
  print("Building container locally.")
  subprocess.call(shlex.split("bazel run //{}:{}".format(package, target)))
  print("Testing container locally.")
  subprocess.call(
      "bazel test //{}:{}-test".format(package, target).split())
  print("Tagging container.")
  subprocess.call(shlex.split("docker tag bazel/{}:{} {}:latest".format(
      package, target, type_)))
  print(("\n{TYPE}:lastest container is now available to use.\n"
          "To try it: docker run -it {TYPE}:latest \n").format(TYPE=type_))

def cloud_build(project_root, project, container, tag, async_, bucket, package, target, tarball):
  '''Runs the build in the cloud. More info in module docstring at the top.
  '''
  print("Building container in Google Cloud Container Builder.")
  # Setup GCP project id for the build
  subprocess.call(shlex.split("gcloud config set project {}".format(project)))
  # Ensure all BUILD files under /third_party have the right permission.
  # This is because in some systems the BUILD files under /third_party
  # (after git clone) will be with permission 640 and the build will
  # fail in Container Builder.
  for dirpath, _, files in os.walk(project_root + "/third_party"):
    for f in files:
      full_path = os.path.join(dirpath, f)
      os.chmod(full_path, 0o644)

  config_file = "{}/container/cloudbuild.yaml".format(project_root)
  extra_substitution = ",_BUCKET={},_TARBALL={}".format(bucket, tarball)
  if not bucket:
    config_file = "{}/container/cloudbuild_no_bucket.yaml".format(
        project_root)
    extra_substitution = ""
  async_arg = ""
  if async_:
    async_arg = "--async"
  subprocess.call(shlex.split((
      "gcloud container builds submit . "
      "--config={CONFIG} "
      "--substitutions _PROJECT={PROJECT},_CONTAINER={CONTAINER},"
      "_TAG={TAG},_PACKAGE={PACKAGE},_TARGET={TARGET}{EXTRA_SUBSTITUTION} "
      "--machine-type=n1-highcpu-32 "
      "{ASYNC}").format(
          CONFIG=config_file,
          PROJECT=project,
          CONTAINER=container,
          TAG=tag,
          PACKAGE=package,
          TARGET=target,
          EXTRA_SUBSTITUTION=extra_substitution,
          ASYNC=async_arg)))


def parse_arguments():
  """Parses command line arguments for the script.

  Returns:
    args object containing the arguments
  """
  parser = argparse.ArgumentParser(
      add_help=False,
      formatter_class=argparse.RawDescriptionHelpFormatter,
      description="""
Builds the fully-loaded container, with Google Cloud Container Builder or locally.

To build with Google Cloud Container Builder:
$ python build.py -p my-gcp-project -d {container_type} -c {container_name} -t latest -b my_bucket
will produce docker images in Google Container Registry:
    gcr.io/my-gcp-project/{container_type}:latest
and the debian packages installed will be packed as a tarball and stored in
gs://my_bucket for future reference, if -b is specified.
To build locally:
$ python build.py -d {container_type} -l
will produce docker locally as {container_type}:latest

""",
  )

  required = parser.add_argument_group("required arguments")

  required.add_argument(
      "-d,",
      "--type",
      help="Type of the container: see TYPE_TARGET_MAP",
      type=str,
      choices=TYPE_PACKAGE_MAP.keys(),
      required=True)
  required.add_argument("-p", "--project", help="GCP project ID", type=str)
  required.add_argument(
      "-c", "--container", help="Docker container name", type=str)
  required.add_argument(
      "-t", "--tag", help="Docker tag for the image", type=str)

  optional = parser.add_argument_group("optional arguments")

  optional.add_argument(
      "-a",
      "--async",
      help="Asynchronous execute Cloud Container Builder",
      required=False,
      default=False,
      action="store_true")
  optional.add_argument(
      "-b",
      "--bucket",
      help="GCS bucket to store the tarball of debian packages",
      type=str,
      required=False,
      default="")

  optional.add_argument(
      "-h", "--help", help="print this help text and exit", action="help")

  standalone = parser.add_argument_group("standalone arguments")

  standalone.add_argument(
      "-l",
      "--local",
      help="Build container locally",
      default=False,
      action="store_true")

  arguments = parser.parse_args()

  # Check arguments
  if not arguments.local and not \
    (arguments.tag and arguments.project and arguments.container):
    print(
        "error: If build is not local (-l), then -p, -c, and -t are required",
        file=sys.stderr)
    exit(1)

  return arguments


if __name__ == "__main__":
  args = parse_arguments()
  main(args.type, args.project, args.container, args.tag, args.async,
       args.bucket, args.local)
