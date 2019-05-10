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

#!/usr/bin/env bash
# Obtains from given URL the Bazel release source dist, and build Bazel.
# Script requires wget
# Bazel installation requires gcc, g++, jdk, python, zip / unzip
# $1: bazel_url
set -e
echo === Building from source a Bazel release version ===

bazel_url=$1

mkdir -p /src/bazel
cd /src/bazel/
# Use -ca-certificate flag to explicitly tell wget where to look for certs.
wget $bazel_url --no-verbose --ca-certificate=/etc/ssl/certs/ca-certificates.crt -O /tmp/bazel-src.zip
mkdir -p /src/bazel/
unzip /tmp/bazel-src.zip -d /src/bazel/
cd /src/bazel && env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
mv /src/bazel/output/bazel /usr/local/bin/
rm -drf /tmp/bazel-src.zip /src/bazel
