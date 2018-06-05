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

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

load("@bazel_toolchains//rules:docker_config.bzl", "docker_toolchain_autoconfig")
load(
    "@bazel_toolchains//rules:environments.bzl",
    "clang_env",
    "debian8_clang_default_keys",
    "debian8_clang_default_packages",
    "debian8_clang_default_repos",
)

# Created on 2017.10.18
docker_toolchain_autoconfig(
    name = "debian8-clang-0.2.0-bazel_0.7.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.7.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = False,
)

# Created on 2017.11.28
docker_toolchain_autoconfig(
    name = "debian8-clang-0.2.0-bazel_0.8.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.8.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = False,
)

# Created on 2018.01.10
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:62ad7c44890792fdb2c2593fc24cfab7132e3a112d55bd453e09387906ae5e2f
docker_toolchain_autoconfig(
    name = "debian8-clang-0.2.0-bazel_0.9.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.9.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = False,
)

# Created on 2018.02.05
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:e57978199c9eb156bd7f63773387f3a238adf61acd71c4942ad91da50b4f241f
docker_toolchain_autoconfig(
    name = "debian8-clang-0.2.0-bazel_0.10.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.10.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = False,
)

# Created on 2018.02.13
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f
docker_toolchain_autoconfig(
    name = "debian8-clang-0.3.0-bazel_0.10.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.10.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.04.06
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.11.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.11.0",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.04.23
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf
docker_toolchain_autoconfig(
    name = "debian8-clang-0.3.0-bazel_0.12.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.12.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.04.23
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.12.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.12.0",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.04.30
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf
docker_toolchain_autoconfig(
    name = "debian8-clang-0.3.0-bazel_0.13.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.13.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.04.30
# Container: gcr.io/cloud-marketplace/google/clang-debian8@sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.13.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.13.0",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)
