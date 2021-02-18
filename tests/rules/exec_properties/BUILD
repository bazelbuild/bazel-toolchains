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

load(":compare.bzl", "compare_dicts_test")
load("//rules/exec_properties:exec_properties.bzl", "create_rbe_exec_properties_dict")

compare_dicts_test(
    name = "docker_network_compare_test",
    actual = create_rbe_exec_properties_dict(docker_network = "standard"),
    expected = {"dockerNetwork": "standard"},
)

compare_dicts_test(
    name = "multiple_properties_compare_test",
    actual = create_rbe_exec_properties_dict(
        docker_privileged = True,
        os_family = "Windows",
    ),
    expected = {
        "dockerPrivileged": "True",
        "OSFamily": "Windows",
    },
)

compare_dicts_test(
    name = "labels_compare_test",
    actual = create_rbe_exec_properties_dict(labels = {
        "abc": "123",
        "def": "456",
    }),
    expected = {
        "label:abc": "123",
        "label:def": "456",
    },
)
