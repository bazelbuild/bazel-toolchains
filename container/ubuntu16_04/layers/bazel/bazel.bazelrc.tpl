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

# Experimental configs for sanitizers, use --config=xxsan --config=<asan/tsan/msan> (in that order)
# See https://github.com/bazelbuild/bazel/issues/5291.
build:xxsan --copt=-gmlt
build:xxsan --strip=never

build:asan --copt=-fsanitize=address
build:asan --linkopt=-fsanitize=address

build:tsan --copt=-fsanitize=thread
build:tsan --linkopt=-fsanitize=thread

build:msan --copt=-fsanitize=memory
build:msan --linkopt=-fsanitize=memory
build:msan --cxxopt=--stdlib=libc++
build:msan --copt=-fsanitize-memory-track-origins
build:msan --host_crosstool_top=@bazel_toolchains//configs/ubuntu16_04_clang/1.0/bazel_{_BAZEL_CONFIG_VERSION}/default:toolchain
build:msan --crosstool_top=@bazel_toolchains//configs/ubuntu16_04_clang/1.0/bazel_{_BAZEL_CONFIG_VERSION}/msan:toolchain
