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
    "debian8_clang_default_keys",
    "debian8_clang_default_packages",
    "debian8_clang_default_repos",
)

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

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
# Container: marketplace.gcr.io/google/clang-debian8@sha256:62ad7c44890792fdb2c2593fc24cfab7132e3a112d55bd453e09387906ae5e2f
# Clang revision: r319946
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
# Container: marketplace.gcr.io/google/clang-debian8@sha256:e57978199c9eb156bd7f63773387f3a238adf61acd71c4942ad91da50b4f241f
# Clang revision: r319946
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
# Container: marketplace.gcr.io/google/clang-debian8@sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f
# Clang revision: r322167
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
# Container: marketplace.gcr.io/google/clang-debian8@sha256:ac3b1fdc22c0f2b95abe67f2daf33788425fab52d4e6845900bfe1a42443098f
# Clang revision: r322167
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.11.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.11.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.04.23
# Container: marketplace.gcr.io/google/clang-debian8@sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf
# Clang revision: r327695
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
# Container: marketplace.gcr.io/google/clang-debian8@sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf
# Clang revision: r327695
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.12.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.12.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.04.30
# Container: marketplace.gcr.io/google/clang-debian8@sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf
# Clang revision: r327695
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
# Container: marketplace.gcr.io/google/clang-debian8@sha256:213da2494bb763f55363213db45d9bfa5eb906039fc02e6cb2e6637dc4917caf
# Clang revision: r327695
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.13.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.13.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.08
# Container: marketplace.gcr.io/google/clang-debian8@sha256:8bb65bf0a0da8be48bbac07ebe743805f3dc5259203e19517098162bd23a768f
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "debian8-clang-0.3.0-bazel_0.14.1-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.14.1",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.08
# Container: marketplace.gcr.io/google/clang-debian8@sha256:8bb65bf0a0da8be48bbac07ebe743805f3dc5259203e19517098162bd23a768f
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.14.1-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.14.1",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.27
# Container: marketplace.gcr.io/google/clang-debian8@sha256:8bb65bf0a0da8be48bbac07ebe743805f3dc5259203e19517098162bd23a768f
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "debian8-clang-0.3.0-bazel_0.15.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.15.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# Created on 2018.06.27
# Container: marketplace.gcr.io/google/clang-debian8@sha256:8bb65bf0a0da8be48bbac07ebe743805f3dc5259203e19517098162bd23a768f
# Clang revision: r328903
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.15.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.15.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.8.13
# Container: marketplace.gcr.io/google/clang-debian8@sha256:de1116d36eafe16890afd64b6bc6809a3ed5b3597ed7bc857980749270894677
# Clang revision: r337145
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.3.0-bazel_0.16.1-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.16.1",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.8.13
# Container: marketplace.gcr.io/google/clang-debian8@sha256:de1116d36eafe16890afd64b6bc6809a3ed5b3597ed7bc857980749270894677
# Clang revision: r337145
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.3.0-bazel_0.16.1-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.16.1",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.9.6
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.4.0-bazel_0.16.1-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.16.1",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.9.6
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.4.0-bazel_0.16.1-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.16.1",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.9.17
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.4.0-bazel_0.17.1-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.17.1",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.9.17
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.4.0-bazel_0.17.1-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.17.1",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.10.16
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.4.0-bazel_0.18.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.18.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.10.16
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r340178
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.4.0-bazel_0.18.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.18.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.11.2
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r342117
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.4.0-bazel_0.19.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.19.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.11.2
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r342117
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.4.0-bazel_0.19.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.19.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.11.19
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r342117
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.4.0-bazel_0.19.2-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.19.2",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.11.19
# Container: marketplace.gcr.io/google/clang-debian8@sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0
# Clang revision: r342117
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.4.0-bazel_0.19.2-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.19.2",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.12.4
# Container: marketplace.gcr.io/google/clang-debian8@sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.4.0-bazel_0.20.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.20.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.12.4
# Container: marketplace.gcr.io/google/clang-debian8@sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.4.0-bazel_0.20.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.20.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2018.12.27
# Container: marketplace.gcr.io/google/clang-debian8@sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.4.0-bazel_0.21.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.21.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2018.12.27
# Container: marketplace.gcr.io/google/clang-debian8@sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.4.0-bazel_0.21.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.21.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/default.tpl and should not be
# modified directly.
# Created on 2019.1.28
# Container: marketplace.gcr.io/google/clang-debian8@sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "default-debian8-clang-0.4.0-bazel_0.22.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.22.0",
    env = clang_env(),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)

# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on 2019.1.28
# Container: marketplace.gcr.io/google/clang-debian8@sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395
# Clang revision: r346485
docker_toolchain_autoconfig(
    name = "msan-debian8-clang-0.4.0-bazel_0.22.0-autoconfig",
    additional_repos = debian8_clang_default_repos(),
    base = "@debian8-clang//image",
    bazel_version = "0.22.0",
    env = dicts.add(
        clang_env(),
        {
            "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
        },
    ),
    keys = debian8_clang_default_keys(),
    packages = debian8_clang_default_packages(),
    tags = ["manual"],
    test = True,
)
