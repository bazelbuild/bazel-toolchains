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
    "ubuntu16_04_clang_default_keys",
    "ubuntu16_04_clang_default_packages",
    "ubuntu16_04_clang_default_repos",
)

# Update the following (if needed) in new config releases.
LATEST_CONFIG_VERSION = "1.1"

LATEST_BAZEL_VERSION = "0.18.0"

CONFIG_TYPES = [
    "default",
    "msan",
]

# DO NOT depend on the following latest alias in your production jobs.
# These are for internal and our CI use only. We DO NOT guarantee that they
# will always work.
[alias(
    name = "latest_crosstool_top_" + config_type,
    actual = LATEST_CONFIG_VERSION + "/bazel_" + LATEST_BAZEL_VERSION + "/" + config_type + ":toolchain",
) for config_type in CONFIG_TYPES]

[alias(
    name = "latest_toolchain_" + config_type,
    actual = LATEST_CONFIG_VERSION + "/bazel_" + LATEST_BAZEL_VERSION + "/cpp:cc-toolchain-clang-x86_64-" + config_type,
) for config_type in CONFIG_TYPES]

alias(
    name = "latest_platform",
    actual = LATEST_CONFIG_VERSION + ":rbe_ubuntu1604_jdk8",
)

alias(
    name = "latest_javabase",
    actual = LATEST_CONFIG_VERSION + ":jdk8",
)

# Created on 2018.05.09
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "ubuntu16_04-clang-1.0-bazel_0.13.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.13.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.05.09
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.0-bazel_0.13.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.13.0",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.08
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "ubuntu16_04-clang-1.0-bazel_0.14.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.14.1",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.08
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.0-bazel_0.14.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.14.1",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.27
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "ubuntu16_04-clang-1.0-bazel_0.15.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.15.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.27
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.0-bazel_0.15.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.15.0",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.8.13
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:fbf123ca7c7696f53864da4f7d1d9470f9ef4ebfabc4344f44173d1951faee6f
# Clang revision: r337145
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.0-bazel_0.16.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.16.1",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.8.13
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:fbf123ca7c7696f53864da4f7d1d9470f9ef4ebfabc4344f44173d1951faee6f
# Clang revision: r337145
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.0-bazel_0.16.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.16.1",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.9.6
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.1-bazel_0.16.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.16.1",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.9.6
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.16.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.16.1",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.9.17
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.1-bazel_0.17.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.17.1",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.9.17
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.17.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.17.1",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.10.16
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.1-bazel_0.18.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.18.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.10.16
# Container: gcr.io/cloud-marketplace/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.18.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.18.0",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)
