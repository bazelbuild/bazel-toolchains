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
""" Definitions to create BUILD files for rbe_autoconfig"""

load(
    "//rules/rbe_repo:util.bzl",
    "CC_CONFIG_DIR",
    "JAVA_CONFIG_DIR",
    "PLATFORM_DIR",
)

_CC_TOOLCHAIN = ":cc-compiler-k8"

def use_standard_config(ctx):
    """Produces BUILD files with alias for the C++/Java toolchain targets. 

    Args:
      ctx: the Bazel context object.
    """
    print("Using checked-in configs.")

    if ctx.attr.create_cc_configs:
        # Create the BUILD file with the alias for the cc_toolchain_suite
        template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:BUILD.cc_alias.tpl"))
        toolchain = ("@bazel_toolchains//configs/ubuntu16_04_clang/{version}/bazel_{bazel_version}/{cc_dir}:toolchain".format(
            version = ctx.attr.config_version,
            bazel_version = ctx.attr.bazel_version,
            cc_dir = CC_CONFIG_DIR,
        ))
        ctx.template(
            CC_CONFIG_DIR + "/BUILD",
            template,
            {
                "%{toolchain}": toolchain,
            },
            False,
        )

    if ctx.attr.create_java_configs:
        # Create the BUILD file with the alias for the java_runtime
        template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:BUILD.java_alias.tpl"))
        java_runtime = ("@bazel_toolchains//configs/ubuntu16_04_clang/{version}/bazel_{bazel_version}/{java_dir}:jdk".format(
            version = ctx.attr.config_version,
            bazel_version = ctx.attr.bazel_version,
            java_dir = JAVA_CONFIG_DIR,
        ))

        ctx.template(
            JAVA_CONFIG_DIR + "/BUILD",
            template,
            {
                "%{java_runtime}": java_runtime,
            },
            False,
        )

def create_java_runtime(ctx, java_home):
    """Creates a BUILD file with the java_runtime target. 

    Args:
      ctx: the Bazel context object.
      java_home: the seleceted/resolved location for java_home.
    """
    template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:BUILD.java.tpl"))
    ctx.template(
        JAVA_CONFIG_DIR + "/BUILD",
        template,
        {
            "%{java_home}": java_home,
        },
        False,
    )

def create_platform(ctx, image_name, name):
    """Creates a BUILD file with the cc_toolchain and platform targets. 

    Args:
      ctx: the Bazel context object.
      image_name: the name of the image.
      name: name of rbe_autoconfig repo rule.
    """

    cc_toolchain_target = "@" + name + "//" + CC_CONFIG_DIR + _CC_TOOLCHAIN

    # A checked in config was found
    if ctx.attr.config_version:
        cc_toolchain_target = ("@bazel_toolchains//configs/ubuntu16_04_clang/{version}/bazel_{bazel_version}/{cc_dir}{target}".format(
            version = ctx.attr.config_version,
            bazel_version = ctx.attr.bazel_version,
            cc_dir = CC_CONFIG_DIR,
            target = _CC_TOOLCHAIN,
        ))
    if ctx.attr.output_base:
        cc_toolchain_target = "//" + ctx.attr.output_base + "/bazel_" + ctx.attr.bazel_version
        if ctx.attr.config_dir:
            cc_toolchain_target += "/" + ctx.attr.config_dir
        cc_toolchain_target += "/cc" + _CC_TOOLCHAIN
    template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:BUILD.platform.tpl"))
    exec_compatible_with = ("\"" +
                            ("\",\n        \"").join(ctx.attr.exec_compatible_with) +
                            "\",")
    target_compatible_with = ("\"" +
                              ("\",\n        \"").join(ctx.attr.target_compatible_with) +
                              "\",")
    ctx.template(
        PLATFORM_DIR + "/BUILD",
        template,
        {
            "%{cc_toolchain}": cc_toolchain_target,
            "%{exec_compatible_with}": exec_compatible_with,
            "%{image_name}": image_name,
            "%{target_compatible_with}": target_compatible_with,
        },
        False,
    )
