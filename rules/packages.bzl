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
"""packages.bzl contains definitions of functions that return packages.

Uses package_names.bzl to resolve packages needed for
tools installed in different containers.
"""

load(
    "@bazel_package_bundle//file:packages.bzl",
    bazel_packages="packages",
)
load(
    "@jessie_package_bundle//file:packages.bzl",
    jessie_packages="packages",
)
load(
    "@trusty_package_bundle//file:packages.bzl",
    trusty_packages="packages",
)
load(
    "@xenial_package_bundle//file:packages.bzl",
    xenial_packages="packages",
)


def get_jessie_packages(pkg_list):
  """Common function for getting jessie packages."""
  return [jessie_packages[p] for p in pkg_list]


def get_trusty_packages(pkg_list):
  """Common function for getting trusty packages."""
  return [trusty_packages[p] for p in pkg_list]


def get_xenial_packages(pkg_list):
  """Common function for getting xenial packages."""
  return [xenial_packages[p] for p in pkg_list]
