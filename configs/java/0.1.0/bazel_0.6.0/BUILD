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

licenses(["notice"])  # Apache 2.0

java_toolchain(
    name = "remote_toolchain",
    bootclasspath = ["@bazel_tools//tools/jdk:bootclasspath"],
    encoding = "UTF-8",
    extclasspath = ["@bazel_tools//tools/jdk:extclasspath"],
    forcibly_disable_header_compilation = 0,
    genclass = ["@bazel_tools//tools/jdk:genclass"],
    header_compiler = ["@bazel_tools//tools/jdk:turbine"],
    ijar = ["@bazel_tools//third_party/ijar:ijar"],
    javabuilder = ["@bazel_tools//tools/jdk:javabuilder"],
    javac = ["@bazel_tools//third_party/java/jdk/langtools:javac_jar"],
    javac_supports_workers = 1,
    jvm_opts = [
        "-XX:+TieredCompilation",
        "-XX:TieredStopAtLevel=1",
        "-Xbootclasspath/p:$(location @bazel_tools//third_party/java/jdk/langtools:javac_jar)",
    ],
    misc = [
        "-XDskipDuplicateBridges=true",
    ],
    singlejar = ["@bazel_tools//src/tools/singlejar:singlejar"],
    source_version = "8",
    target_version = "8",
)
