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

from __future__ import print_function
import argparse
import os
import subprocess

# Map to store all supported container type and the package of target to build it.
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
    "ubuntu16_04-bazel": "bazel",
    "ubuntu16_04-bazel-docker": "bazel_docker",
}

# Map to store all supported container type and the name of target to build it.
TYPE_TARBALL_MAP = {
    "rbe-debian8": "toolchain-packages.tar",
    "rbe-debian9": "toolchain-packages.tar",
    "rbe-ubuntu16_04": "toolchain-packages.tar",
    "ubuntu16_04-bazel": "bazel-packages.tar",
    "ubuntu16_04-bazel-docker": "bazel_docker-packages.tar",
}


def main(type_, project, container, tag, async_, bucket, local):
    project_root = subprocess.check_output(
        "git rev-parse --show-toplevel", shell=True).strip()
    package = TYPE_PACKAGE_MAP[type_]
    target = TYPE_TARGET_MAP[type_]
    tarball = TYPE_TARBALL_MAP[type_]

    # We need to start the build from the root of the project, so that we can
    # mount the full root directory (to use bazel builder properly).
    os.chdir(project_root)
    # We need to run clean to make sure we don't mount local build outputs
    subprocess.call("bazel clean", shell=True)

    if local:
        print("Building container locally.")
        subprocess.call(
            "bazel run //{}:{}".format(package, target), shell=True)
        print("Testing container locally.")
        subprocess.call(
            "bazel test //{}:{}-test".format(package, target), shell=True)
        print("Tagging container.")
        subprocess.call(
            "docker tag bazel/{}:{} {}:latest".format(package, tarball, type_))
        print(("\n" +
               "{TYPE}:lastest container is now available to use.\n" +
               "To try it: docker run -it {TYPE}:latest \n").format(TYPE=type_)
              )
    else:
        print("Building container in Google Cloud Container Builder.")
        # Setup GCP project id for the build
        subprocess.call(
            "gcloud config set project {}".format(project), shell=True)
        # Ensure all BUILD files under /third_party have the right permission.
        # This is because in some systems the BUILD files under /third_party (after git clone)
        # will be with permission 640 and the build will fail in Container Builder.
        for dirpath, _, files in os.walk(project_root+'/third_party'):
            for f in files:
                full_path = os.path.join(dirpath, f)
                os.chmod(full_path, 0o644)

        config_file = "{}/container/cloudbuild.yaml".format(project_root)
        extra_substitution = ",_BUCKET={},_TARBALL={}".format(bucket, tarball)
        if not bucket:
            config_file = "{}/container/cloudbuild_no_bucket.yaml".format(
                project_root)
            extra_substitution = ""
        ASYNC = ""
        if async_:
            ASYNC = "--async"
        subprocess.call(
            "gcloud container builds submit . \
            --config={CONFIG} \
            --substitutions _PROJECT={PROJECT},_CONTAINER={CONTAINER},_TAG={TAG},_PACKAGE={PACKAGE},_TARGET={TARGET}{EXTRA_SUBSTITUTION} \
            --machine-type=n1-highcpu-32 \
            {ASYNC}".format(
            CONFIG=config_file,
            PROJECT=project,
            CONTAINER=container,
            TAG=tag,
            PACKAGE=package,
            TARGET=target,
            EXTRA_SUBSTITUTION=extra_substitution,
            ASYNC=ASYNC),
        shell=True)


'''
usage: build.py [-h] [-a] [-b BUCKET] -l
                type project container tag

Builds the fully-loaded container, with Google Cloud Container Builder or
locally.

positional arguments:
  type                  Type of the container: see TYPE_TARGET_MAP
  project               GCP project ID
  container             Docker container name
  tag                   Docker tag for the image

optional arguments:
  -h, --help            show this help message and exit
  -a, --async           Asynchronous execute Cloud Container Builder
  -b BUCKET, --bucket BUCKET
                        GCS bucket to store the tarball of debian packages
  -l, --local           Build container locally




'''


if __name__ == "__main__":
  parser = argparse.ArgumentParser(
      description=
      "Builds the fully-loaded container, with Google Cloud Container Builder or locally."
  )

  parser.add_argument(
      "type",
      help="Type of the container: see TYPE_TARGET_MAP",
      type=str,
      choices=TYPE_PACKAGE_MAP.keys())
  parser.add_argument("project", help="GCP project ID", type=str)
  parser.add_argument("container", help="Docker container name", type=str)
  parser.add_argument("tag", help="Docker tag for the image", type=str)

  parser.add_argument(
      "-a",
      "--async",
      help="Asynchronous execute Cloud Container Builder",
      required=False,
      default=False,
      action="store_true")
  parser.add_argument(
      "-b",
      "--bucket",
      help="GCS bucket to store the tarball of debian packages",
      type=str,
      required=False,
      default="")
  parser.add_argument(
      "-l",
      "--local",
      help="Build container locally",
      required=True,
      default=False,
      action="store_true")

  args = parser.parse_args()

  main(args.type, args.project, args.container, args.tag, args.async,
       args.bucket, args.local)
