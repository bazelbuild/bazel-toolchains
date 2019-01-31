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
"""Default dictionaries of env variables."""

def gcc_env():
    return {
        "ABI_LIBC_VERSION": "glibc_2.19",
        "ABI_VERSION": "gcc",
        "BAZEL_COMPILER": "gcc",
        "BAZEL_HOST_SYSTEM": "i686-unknown-linux-gnu",
        "BAZEL_TARGET_CPU": "k8",
        "BAZEL_TARGET_LIBC": "glibc_2.19",
        "BAZEL_TARGET_SYSTEM": "x86_64-unknown-linux-gnu",
        "CC_TOOLCHAIN_NAME": "linux_gnu_x86",
    }

def clang_env():
    return {
        "ABI_LIBC_VERSION": "glibc_2.19",
        "ABI_VERSION": "clang",
        "BAZEL_COMPILER": "clang",
        "BAZEL_HOST_SYSTEM": "i686-unknown-linux-gnu",
        "BAZEL_TARGET_CPU": "k8",
        "BAZEL_TARGET_LIBC": "glibc_2.19",
        "BAZEL_TARGET_SYSTEM": "x86_64-unknown-linux-gnu",
        "CC": "clang",
        "CC_TOOLCHAIN_NAME": "linux_gnu_x86",
    }

def debian8_clang_default_packages():
    return [
        "bazel",
        "ca-certificates-java=20161107'*'",
        "curl",
        "git",
        "openjdk-8-jdk-headless",
        "openjdk-8-jre-headless",
        "python-dev",
        "unzip",
        "wget",
        "zip",
    ]

def debian8_clang_default_repos():
    return [
        "deb http://deb.debian.org/debian jessie-backports main",
        bazel_repo(),
    ]

def debian8_clang_default_keys():
    return bazel_key()

def ubuntu16_04_clang_default_packages():
    return [
        "bazel",
        "ca-certificates-java",
        "curl",
        "git",
        "openjdk-8-jdk-headless",
        "openjdk-8-jre-headless",
        "python-dev",
        "unzip",
        "wget",
        "zip",
    ]

def ubuntu16_04_clang_default_repos():
    return [
        bazel_repo(),
    ]

def ubuntu16_04_clang_default_keys():
    return bazel_key()

def bazel_key():
    return [
        "@bazel_gpg//file",
    ]

def bazel_repo():
    return "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8"
