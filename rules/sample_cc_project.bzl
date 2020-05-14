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
"""Generate a sample cc project for generating toolchain configs"""

def generate_sample_cc_project(ctx):
    """Generates a sample cc project in the repository context

    Args:
      ctx: the Bazel repository context object

    Returns:
      string path to the generated project in the repository
    """

    ctx.file(
        "cc-sample-project/BUILD",
        """package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

filegroup(
    name = "srcs",
    srcs = [
        "BUILD",
        "test.cc",
    ],
)

cc_test(
    name = "test",
    srcs = ["test.cc"],
)
""",
    )
    ctx.file(
        "cc-sample-project/test.cc",
        """#include <iostream>

int main() {
  std::cout << "Hello test!" << std::endl;
  return 0;
}

""",
    )
    ctx.file("cc-sample-project/WORKSPACE", "")

    return str(ctx.path("cc-sample-project"))
