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
"""usage: build.py -d TYPE [-p PROJECT] [-c CONTAINER] [-t TAG]
                   -v BAZEL_VERSION [-a] [-b BUCKET] [-h] [-m MAP] [-l]

Builds a toolchain container, with Google Cloud Container Builder or locally.

IF THIS SCRIPT IS CALLED FROM OUTSIDE OF THE BAZEL-TOOLCHAINS REPO, THE
BAZEL-TOOLCHAINS REPO MUST BE A SUBDIRECTORY OF THE OUTER PROJECT. OUTER PROJECT
MUST ALSO HAVE bazel_toolchains AS A DEPENDENCY
Ex:
cd <your project with your own build targets>
git clone https://github.com/bazelbuild/bazel-toolchains.git
python bazel-toolchains/container/build.py [args]

Note: a file path passed to the -m param must point to a file in the form
descibed below
(except TYPE_TARBALL_MAP is not required if the -b arg is not used)

To build with Google Cloud Container Builder:
$ python build.py -p my-gcp-project -d {container_type} -c {container_name} -t
latest -b my_bucket
will produce docker images in Google Container Registry:
    gcr.io/my-gcp-project/{container_type}:latest
and the debian packages installed will be packed as a tarball and stored in
gs://my_bucket for future reference, if -b is specified.
To build locally:
$ python build.py -d {container_type} -l
will produce docker locally as {container_type}:latest

required arguments:
  -d TYPE, --type TYPE  Type of the container: see SUPPORTED_TYPES
required arguments (for cloud build):
  -p PROJECT, --project PROJECT
                        GCP project ID
  -c CONTAINER, --container CONTAINER
                        Docker container name
  -t TAG, --tag TAG     Docker tag for the image
  -v BAZEL_VERSION, --bazel_version BAZEL_VERSION
                        The version of Bazel to build the image with on Google
                        Cloud Container Builder, e.g. 0.15.1 (supported
                        versions can be seen at
                        //container/ubuntu16_04/layers/bazel/version.bzl)

optional arguments:
  -h, --help            print this help text and exit

optional arguments (for cloud build):
  -a, --async           Asynchronous execute Cloud Container Builder
  -b BUCKET, --bucket BUCKET
                        GCS bucket to store the tarball of debian packages
  -m MAP, --map MAP     path (can be absolute or relative) to file containing
                        3 maps to override the default ones defined below
                        (TYPE_PACKAGE_MAP, TYPE_TARGET_MAP, and
                        TYPE_TARBALL_MAP)


standalone arguments:
  -l, --local           Build container locally
"""

from __future__ import print_function
import argparse
import imp
import os
import shlex
import subprocess
import sys

LATEST_BAZEL_VERSION = "0.17.1"

SUPPORTED_TYPES = [
    "rbe-debian8", "rbe-debian9", "rbe-ubuntu16_04", "ubuntu16_04-bazel",
    "ubuntu16_04-bazel-docker-gcloud", "debian8-bazel", "ubuntu14_04-bazel"
]

# File passed in -m must include the following 3 maps
# (all 3 with the same keys, and corresponding values):
# =========== STARTING HERE ===========

# Map to store all supported container type and
# the package of target to build it.
TYPE_PACKAGE_MAP = {
    "rbe-debian8": "container/debian8/builders/rbe-debian8",
    "rbe-debian9": "container/experimental/rbe-debian9",
    "rbe-ubuntu16_04": "container/ubuntu16_04/builders/rbe-ubuntu16_04",
    "ubuntu16_04-bazel": "container/ubuntu16_04/builders/bazel",
    "ubuntu16_04-bazel-docker-gcloud":
        "container/ubuntu16_04/builders/bazel_docker_gcloud",
    "debian8-bazel": "container/debian8/builders/bazel",
    "ubuntu14_04-bazel": "container/ubuntu14_04/builders/bazel",
}

# Map to store all supported container type and the name of target to build it.
TYPE_TARGET_MAP = {
    "rbe-debian8": "toolchain",
    "rbe-debian9": "toolchain",
    "rbe-ubuntu16_04": "toolchain",
    "ubuntu16_04-bazel": "bazel_{}".format(LATEST_BAZEL_VERSION),
    "ubuntu16_04-bazel-docker-gcloud":
        "bazel_{}_docker_gcloud".format(LATEST_BAZEL_VERSION),
    "debian8-bazel": "bazel_{}".format(LATEST_BAZEL_VERSION),
    "ubuntu14_04-bazel": "bazel_{}".format(LATEST_BAZEL_VERSION),
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
        "bazel_{}_intermediate-packages.tar".format(LATEST_BAZEL_VERSION),
    "ubuntu16_04-bazel-docker-gcloud":
        "bazel_{}_docker_gcloud-packages.tar".format(LATEST_BAZEL_VERSION),
    "debian8-bazel":
         "bazel_{}_intermediate-packages.tar".format(LATEST_BAZEL_VERSION),
    "ubuntu14_04-bazel":
        "bazel_{}_intermediate-packages.tar".format(LATEST_BAZEL_VERSION),
}

# =========== ENDING HERE ===========
assert set(SUPPORTED_TYPES) \
        == set(TYPE_PACKAGE_MAP.keys()) \
        == set(TYPE_TARGET_MAP.keys()) \
        == set(TYPE_TARBALL_MAP.keys()), \
            "TYPES ARE OUT OF SYNC"


def main(type_,
         project,
         container,
         tag,
         async_,
         bucket,
         local,
         bazel_version,
         map=None):
  """Runs the build. More info in module docstring at the top.
  """
  type_package_map = TYPE_PACKAGE_MAP
  type_target_map = TYPE_TARGET_MAP
  type_tarball_map = TYPE_TARBALL_MAP

  if map:  # Override the map values
    try:
      map_module = imp.load_source("map", map)
    except IOError as e:
      print("Error reading map file.\n", e)

    try:
      type_package_map = map_module.TYPE_PACKAGE_MAP
      type_target_map = map_module.TYPE_TARGET_MAP
      if bucket:
        type_tarball_map = map_module.TYPE_TARBALL_MAP
    except AttributeError as e:
      print("Error getting attributes from map file.\n", e)

  # Gets the project root (for calling bazel targets)
  project_root = subprocess.check_output(
      shlex.split("git rev-parse --show-toplevel")).strip()
  package = type_package_map[type_]
  target = type_target_map[type_]
  tarball = None
  if bucket:
    tarball = type_tarball_map[type_]

  # Gets the base directory of the bazel-toolchains repo (relative to project_root)
  # This is for referencing yaml files and mounting the project to gcloud.
  # Allows the bazel-toolchains repo to be cloned in any subdirectory
  # of another project and bazel_toolchains_base_dir will store the relative path
  # from the root of that git project to the root of the bazel-toolchains git project.
  # Ex. If we are in folder foo and the structure looks like this:
  # foo/
  #     subdir/
  #         bazel-toolchains
  #     ...
  #
  # Then if we call build.py with the terminal running in foo,
  # bazel_toolchains_base_dir == "subdir/bazel-toolchains"
  # (This also allows for renaming of the bazel-toolchains folder as the variable
  # will store the path regardless of the directory names)
  os.chdir(os.path.dirname(__file__))
  bazel_toolchains_base_dir = os.path.relpath(
      subprocess.check_output(
          shlex.split("git rev-parse --show-toplevel")).strip(), project_root)

  # We need to start the build from the root of the project, so that we can
  # mount the full root directory (to use bazel builder properly).
  os.chdir(project_root)
  # We need to run clean to make sure we don't mount local build outputs
  subprocess.check_call(["bazel", "clean"])

  if local:
    local_build(type_, package, target)
  else:

    cloud_build(project, container, tag, async_, package, target, bazel_version,
                bazel_toolchains_base_dir, bucket, tarball)


def local_build(type_, package, target):
  """Runs the build locally. More info in module docstring at the top.
  """
  print("Building container locally.")
  subprocess.check_call(
      shlex.split("bazel run //{}:{}".format(package, target)))
  print("Testing container locally.")
  subprocess.check_call("bazel test //{}:{}-test".format(package,
                                                         target).split())
  print("Tagging container.")
  subprocess.check_call(
      shlex.split("docker tag bazel/{}:{} {}:latest".format(
          package, target, type_)))
  print(("\n{TYPE}:lastest container is now available to use.\n"
         "To try it: docker run -it {TYPE}:latest \n").format(TYPE=type_))


def cloud_build(project,
                container,
                tag,
                async_,
                package,
                target,
                bazel_version,
                bazel_toolchains_base_dir,
                bucket=None,
                tarball=None):
  """Runs the build in the cloud. More info in module docstring at the top.
  """

  print("Building container in Google Cloud Container Builder.")

  # Setup GCP project id for the build
  subprocess.check_call(
      shlex.split("gcloud config set project {}".format(project)))
  # Ensure all BUILD files under /third_party have the right permission.
  # This is because in some systems the BUILD files under /third_party
  # (after git clone) will be with permission 640 and the build will
  # fail in Container Builder.
  for dirpath, _, files in os.walk(
      os.path.join(bazel_toolchains_base_dir, "third_party")):
    for f in files:
      full_path = os.path.join(dirpath, f)
      os.chmod(full_path, 0o644)

  # Gets the yaml relative to the bazel-toolchains root, regardless of what directory it was called from
  # MUST BE UPDATED IF THE YAML FILE IS MOVED
  config_file = "{}/container/cloudbuild.yaml".format(bazel_toolchains_base_dir)
  extra_substitution = ",_BUCKET={},_TARBALL={}".format(bucket, tarball)
  if not bucket:
    # Gets the yaml relative to the bazel-toolchains root, regardless of what directory it was called from
    # MUST BE UPDATED IF THE YAML FILE IS MOVED
    config_file = "{}/container/cloudbuild_no_bucket.yaml".format(
        bazel_toolchains_base_dir)
    extra_substitution = ""

  async_arg = ""
  if async_:
    async_arg = "--async"
  subprocess.check_call(
      shlex.split(
          ("gcloud builds submit . "
           "--config={CONFIG} "
           "--substitutions _PROJECT={PROJECT},_CONTAINER={CONTAINER},"
           "_BAZEL_VERSION={BAZEL_VERSION},"
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
               ASYNC=async_arg,
               BAZEL_VERSION=bazel_version)))


def parse_arguments():
  """Parses command line arguments for the script.

  Returns:
    args object containing the arguments
  """
  parser = argparse.ArgumentParser(
      add_help=False,
      formatter_class=argparse.RawDescriptionHelpFormatter,
      description="""
Builds a toolchain container, with Google Cloud Container Builder or locally.

IF THIS SCRIPT IS CALLED FROM OUTSIDE OF THE BAZEL-TOOLCHAINS REPO, THE BAZEL-TOOLCHAINS REPO
MUST BE A SUBDIRECTORY OF THE OUTER PROJECT. OUTER PROJECT MUST ALSO HAVE bazel_toolchains AS
A DEPENDENCY
Ex:
cd <your project with your own build targets>
git clone https://github.com/bazelbuild/bazel-toolchains.git
python bazel-toolchains/container/build.py [args]

Note: a file path passed to the -m param must point to a file in the form descibed above
(except TYPE_TARBALL_MAP is not required if the -b arg is not used)

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
      help="Type of the container: see SUPPORTED_TYPES",
      type=str,
      choices=TYPE_PACKAGE_MAP.keys(),
      required=True)

  required_cloud = parser.add_argument_group(
      "required arguments (for cloud build)")
  required_cloud.add_argument(
      "-p", "--project", help="GCP project ID", type=str)
  required_cloud.add_argument(
      "-c", "--container", help="Docker container name", type=str)
  required_cloud.add_argument(
      "-t", "--tag", help="Docker tag for the image", type=str)

  required_cloud.add_argument(
      "-v",
      "--bazel_version",
      help=
      "The version of Bazel to build the image with on Google Cloud Container Builder, e.g. 0.15.1 "
      "(supported versions can be seen at //container/ubuntu16_04/layers/bazel/version.bzl)",
      type=str)

  optional = parser.add_argument_group("optional arguments")
  optional.add_argument(
      "-h", "--help", help="print this help text and exit", action="help")

  optional_cloud = parser.add_argument_group(
      "optional arguments (for cloud build)")

  optional_cloud.add_argument(
      "-a",
      "--async",
      help="Asynchronous execute Cloud Container Builder",
      required=False,
      default=False,
      action="store_true")
  optional_cloud.add_argument(
      "-b",
      "--bucket",
      help="GCS bucket to store the tarball of debian packages",
      type=str,
      required=False,
      default="")
  optional_cloud.add_argument(
      "-m",
      "--map",
      help=
      "path (can be absolute or relative) to file containing 3 maps to "
      "override the default ones defined below "
      "(TYPE_PACKAGE_MAP, TYPE_TARGET_MAP, and TYPE_TARBALL_MAP)",
      type=str,
      default=None)

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
    (arguments.tag and arguments.project and arguments.container and arguments.bazel_version):
    print(
        "error: If build is not local (-l), then -p, -c, -t, and -v are required",
        file=sys.stderr)
    exit(1)

  if arguments.local and (arguments.tag or arguments.map or arguments.project or
                          arguments.bazel_version or arguments.container or
                          arguments.bucket or arguments.async):
    print(
        "error: If build is local (-l), then only -d is allowed (and required)",
        file=sys.stderr)
    exit(1)

  return arguments


if __name__ == "__main__":
  args = parse_arguments()
  main(args.type, args.project, args.container, args.tag, args.async,
       args.bucket, args.local, args.bazel_version, args.map)
