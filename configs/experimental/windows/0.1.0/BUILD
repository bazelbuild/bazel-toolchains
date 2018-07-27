# Copyright 2016 The Bazel Authors. All rights reserved.
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

package(default_visibility = ["//visibility:public"])

java_runtime(
    name = "jdk8",
    srcs = [],
    java_home = "C:/openjdk",
)

# Below are a number of almost identical Windows platforms. It is desirable to
# be able to vary the "Pool" property at runtime, but since it has to be baked
# into this BUILD file it's not possible. As a compromise, provide one platform
# for each of the default pool, and three generic Windows pools.

# RBE Windows 1803 image that uses any pool.
platform(
    name = "rbe",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:windows",
    ],
    remote_execution_properties = """
        properties:{
          name:"container-image"
          value:"docker://gcr.io/rbe-windows-test-images/windowstest@sha256:81b032d1496868a5b415973e33a0fa4076e5136dc9dc59ba816dde1f3716db80"
        }
        properties:{
          name: "OSFamily" value: "Windows"
        }
        """,
)

# RBE Windows 1803 image that uses "default" pool.
platform(
    name = "rbe_default",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:windows",
    ],
    remote_execution_properties = """
        properties:{
          name:"container-image"
          value:"docker://gcr.io/rbe-windows-test-images/windowstest@sha256:81b032d1496868a5b415973e33a0fa4076e5136dc9dc59ba816dde1f3716db80"
        }
        properties:{
          name: "OSFamily" value: "Windows"
        }
        properties:{
          name: "Pool" value: "default"
        }
        """,
)

# RBE Windows 1803 image that uses "windows_1" pool.
platform(
    name = "rbe_windows_1",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:windows",
    ],
    remote_execution_properties = """
        properties:{
          name:"container-image"
          value:"docker://gcr.io/rbe-windows-test-images/windowstest@sha256:81b032d1496868a5b415973e33a0fa4076e5136dc9dc59ba816dde1f3716db80"
        }
        properties:{
          name: "OSFamily" value: "Windows"
        }
        properties:{
          name: "Pool" value: "windows_1"
        }
        """,
)

# RBE Windows 1803 image that uses "windows_2" pool.
platform(
    name = "rbe_windows_2",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:windows",
    ],
    remote_execution_properties = """
        properties:{
          name:"container-image"
          value:"docker://gcr.io/rbe-windows-test-images/windowstest@sha256:81b032d1496868a5b415973e33a0fa4076e5136dc9dc59ba816dde1f3716db80"
        }
        properties:{
          name: "OSFamily" value: "Windows"
        }
        properties:{
          name: "Pool" value: "windows_2"
        }
        """,
)

# RBE Windows 1803 image that uses "windows_3" pool.
platform(
    name = "rbe_windows_3",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:windows",
    ],
    remote_execution_properties = """
        properties:{
          name:"container-image"
          value:"docker://gcr.io/rbe-windows-test-images/windowstest@sha256:81b032d1496868a5b415973e33a0fa4076e5136dc9dc59ba816dde1f3716db80"
        }
        properties:{
          name: "OSFamily" value: "Windows"
        }
        properties:{
          name: "Pool" value: "windows_3"
        }
        """,
)
