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

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_toolchains//rules:docker_config.bzl", "docker_toolchain_autoconfig")
load(
    "@bazel_toolchains//rules:environments.bzl",
    "clang_env",
    "ubuntu16_04_clang_default_keys",
    "ubuntu16_04_clang_default_packages",
    "ubuntu16_04_clang_default_repos",
)

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

# This is the platform used by BuildKite CI that enables
# docker capabilities for spinning up sibling containers
platform(
    name = "platform_docker",
    parents = ["@buildkite_config//config:platform"],
    remote_execution_properties = """
        {PARENT_REMOTE_EXECUTION_PROPERTIES}
        properties: {
          name: "dockerSiblingContainers"
          value: "true"
        }
        """,
)

# Created on 2018.05.09
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
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
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.0-bazel_0.13.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.13.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.08
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
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
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.0-bazel_0.14.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.14.1",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.27
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
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
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:d553634f23f7c437ca35bbc4b6f1f38bb81be32b9ef2df4329dcd36762277bf7
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.0-bazel_0.15.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.15.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.8.13
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:fbf123ca7c7696f53864da4f7d1d9470f9ef4ebfabc4344f44173d1951faee6f
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
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:fbf123ca7c7696f53864da4f7d1d9470f9ef4ebfabc4344f44173d1951faee6f
# Clang revision: r337145
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.0-bazel_0.16.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.16.1",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.9.6
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
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
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.16.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.16.1",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.9.17
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
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
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.17.1-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.17.1",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.10.16
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
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
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.18.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.18.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.11.2
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r342117
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.1-bazel_0.19.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.19.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.11.2
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r342117
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.19.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.19.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.11.19
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r342117
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.1-bazel_0.19.2-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.19.2",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.11.19
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126
# Clang revision: r342117
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.19.2-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.19.2",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.12.4
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:9fe84f7c726419ab77a9680887ec4a518d1910a28284c2955620258db01c7aae
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.1-bazel_0.20.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.20.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.12.4
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:9fe84f7c726419ab77a9680887ec4a518d1910a28284c2955620258db01c7aae
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.20.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.20.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.12.27
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:9fe84f7c726419ab77a9680887ec4a518d1910a28284c2955620258db01c7aae
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.1-bazel_0.21.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.21.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.12.27
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:9fe84f7c726419ab77a9680887ec4a518d1910a28284c2955620258db01c7aae
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.21.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.21.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2019.1.28
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:9fe84f7c726419ab77a9680887ec4a518d1910a28284c2955620258db01c7aae
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.1-bazel_0.22.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.22.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2019.1.28
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:9fe84f7c726419ab77a9680887ec4a518d1910a28284c2955620258db01c7aae
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.1-bazel_0.22.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.22.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2019.2.27
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:963ea21d047664257c91fb0e05d9a6e9acf1481ea1874736af4d4ceed1e02a0c
# Clang revision: r352865
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.2-bazel_0.23.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.23.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2019.2.27
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:963ea21d047664257c91fb0e05d9a6e9acf1481ea1874736af4d4ceed1e02a0c
# Clang revision: r352865
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.2-bazel_0.23.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.23.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2019.3.26
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:963ea21d047664257c91fb0e05d9a6e9acf1481ea1874736af4d4ceed1e02a0c
# Clang revision: r352865
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.2-bazel_0.24.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.24.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2019.3.26
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:963ea21d047664257c91fb0e05d9a6e9acf1481ea1874736af4d4ceed1e02a0c
# Clang revision: r352865
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.2-bazel_0.24.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.24.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2019.5.3
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:ed21de14f213a6dfe55c50663ae5f95c545ae0f8fce065a70ffe6d8bb260d8d6
# Clang revision: r352865
docker_toolchain_autoconfig(
    name = "default-ubuntu16_04-clang-1.2-bazel_0.25.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.25.0",
    env = clang_env(),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2019.5.3
# Container: marketplace.gcr.io/google/clang-ubuntu@sha256:ed21de14f213a6dfe55c50663ae5f95c545ae0f8fce065a70ffe6d8bb260d8d6
# Clang revision: r352865
docker_toolchain_autoconfig(
    name = "msan-ubuntu16_04-clang-1.2-bazel_0.25.0-autoconfig",
    additional_repos = ubuntu16_04_clang_default_repos(),
    base = "@ubuntu16_04-clang//image",
    bazel_version = "0.25.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = ubuntu16_04_clang_default_keys(),
    packages = ubuntu16_04_clang_default_packages(),
    tags = ["manual"],
    test = True,
)
