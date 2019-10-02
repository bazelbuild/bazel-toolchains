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
""" Definitions to create BUILD files for rbe_autoconfig."""

load(
    "//rules/rbe_repo:util.bzl",
    "CC_CONFIG_DIR",
    "JAVA_CONFIG_DIR",
    "PLATFORM_DIR",
)
load("//rules/experimental/rbe:exec_properties.bzl", "create_exec_properties_dict", "merge_dicts")

_CC_TOOLCHAIN = ":cc-compiler-k8"

def create_config_aliases(ctx, toolchain_config_spec_name):
    """Produces BUILD files with alias for the C++ and Java toolchain targets.

    Java toolchain aliases are only created if configs are exported.

    Args:
      ctx: the Bazel context object.
      toolchain_config_spec_name: name of the toolchain config spec
    """
    if ctx.attr.create_cc_configs:
        # Create the BUILD file with the alias for the cc_toolchain_suite
        template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:BUILD.cc_alias.tpl"))
        toolchain = ("@{toolchain_config_repo}//{config_output_base}/{toolchain_config_spec_name}/bazel_{bazel_version}/{cc_dir}:toolchain".format(
            toolchain_config_spec_name = toolchain_config_spec_name,
            bazel_version = ctx.attr.bazel_version,
            cc_dir = CC_CONFIG_DIR,
            config_output_base = ctx.attr.toolchain_config_suite_spec["output_base"],
            toolchain_config_repo = ctx.attr.toolchain_config_suite_spec["repo_name"],
        ))
        ctx.template(
            CC_CONFIG_DIR + "/BUILD",
            template,
            {
                "%{toolchain}": toolchain,
            },
            False,
        )
    if ctx.attr.create_java_configs and ctx.attr.export_configs:
        # Create the BUILD file with the alias for the java_runtime
        template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:BUILD.java_alias.tpl"))
        java_runtime = ("@{toolchain_config_repo}//{config_output_base}/{toolchain_config_spec_name}/bazel_{bazel_version}/{java_dir}:jdk".format(
            toolchain_config_spec_name = toolchain_config_spec_name,
            bazel_version = ctx.attr.bazel_version,
            java_dir = JAVA_CONFIG_DIR,
            config_output_base = ctx.attr.toolchain_config_suite_spec["output_base"],
            toolchain_config_repo = ctx.attr.toolchain_config_suite_spec["repo_name"],
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

def create_export_platform(ctx, image_name, name, toolchain_config_spec_name, use_legacy_platform_definition, exec_properties):
    """Creates a BUILD file (to be exported to output_base) with the cc_toolchain and platform targets.

    Args:
      ctx: the Bazel context object.
      image_name: the name of the image.
      name: name of rbe_autoconfig repo rule.
      toolchain_config_spec_name: name of the toolchain config spec
      use_legacy_platform_definition: Whether to create a platform with remote_execution_properties (legacy) or with exec_properties.
      exec_properties: A string->string dict containing execution properties to be used when creating the platform.
          Will be used only when use_legacy_platform_definition == False. This dict must not contain "container-image".
    """
    cc_toolchain_target = "//" + ctx.attr.toolchain_config_suite_spec["output_base"]
    if toolchain_config_spec_name:
        cc_toolchain_target += "/" + toolchain_config_spec_name
    cc_toolchain_target += "/bazel_" + ctx.attr.bazel_version
    cc_toolchain_target += "/cc" + _CC_TOOLCHAIN
    _create_platform(ctx, image_name, name, cc_toolchain_target, use_legacy_platform_definition, exec_properties)

def create_external_repo_platform(ctx, image_name, name, use_legacy_platform_definition, exec_properties):
    """Creates a BUILD file (to be used with configs in the external repo) with the cc_toolchain and platform targets.

    Args:
      ctx: the Bazel context object.
      image_name: the name of the image.
      name: name of rbe_autoconfig repo rule.
      use_legacy_platform_definition: Whether to create a platform with remote_execution_properties (legacy) or with exec_properties.
      exec_properties: A string->string dict containing execution properties to be used when creating the platform.
          Will be used only when use_legacy_platform_definition == False. This dict must not contain "container-image".
    """
    cc_toolchain_target = "@" + ctx.attr.name + "//" + CC_CONFIG_DIR + _CC_TOOLCHAIN
    _create_platform(ctx, image_name, name, cc_toolchain_target, use_legacy_platform_definition, exec_properties)

def create_alias_platform(ctx, toolchain_config_spec_name, image_name, name, use_legacy_platform_definition, exec_properties):
    """Creates a BUILD file (pointing to checked in config) with the cc_toolchain and platform targets.

    Args:
      ctx: the Bazel context object.
      toolchain_config_spec_name: name of the toolchain config spec.
      image_name: the name of the image.
      name: name of rbe_autoconfig repo rule.
      use_legacy_platform_definition: Whether to create a platform with remote_execution_properties (legacy) or with exec_properties.
      exec_properties: A string->string dict containing execution properties to be used when creating the platform.
          Will be used only when use_legacy_platform_definition == False. This dict must not contain "container-image".
    """
    cc_toolchain_target = ("@{toolchain_config_repo}//{config_output_base}/{toolchain_config_spec_name}/bazel_{bazel_version}/{cc_dir}{target}".format(
        toolchain_config_spec_name = toolchain_config_spec_name,
        bazel_version = ctx.attr.bazel_version,
        cc_dir = CC_CONFIG_DIR,
        config_output_base = ctx.attr.toolchain_config_suite_spec["output_base"],
        target = _CC_TOOLCHAIN,
        toolchain_config_repo = ctx.attr.toolchain_config_suite_spec["repo_name"],
    ))
    _create_platform(ctx, image_name, name, cc_toolchain_target, use_legacy_platform_definition, exec_properties)

# Creates a BUILD file with the cc_toolchain and platform targets
def _create_platform(ctx, image_name, name, cc_toolchain_target, use_legacy_platform_definition, exec_properties):
    template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:BUILD.platform_legacy.tpl")) if use_legacy_platform_definition else ctx.path(Label("@bazel_toolchains//rules/rbe_repo:BUILD.platform.tpl"))
    exec_compatible_with = ("\"" +
                            ("\",\n        \"").join(ctx.attr.exec_compatible_with) +
                            "\",")
    target_compatible_with = ("\"" +
                              ("\",\n        \"").join(ctx.attr.target_compatible_with) +
                              "\",")

    if use_legacy_platform_definition == True and exec_properties:
        fail("exec_properties must not be set when use_legacy_platform_definition is True")

    platform_exec_properties = create_exec_properties_dict(
        container_image = "docker://%s" % image_name,
        os_family = "Linux",
    )
    if use_legacy_platform_definition == False and exec_properties:
        if "container-image" in exec_properties:
            fail("exec_properties must not contain a container image")
        platform_exec_properties = merge_dicts(platform_exec_properties, exec_properties)

    ctx.template(
        PLATFORM_DIR + "/BUILD",
        template,
        {
            "%{cc_toolchain}": cc_toolchain_target,
            "%{exec_compatible_with}": exec_compatible_with,
            "%{image_name}": image_name,
            "%{platform_exec_properties}": "%s" % platform_exec_properties,
            "%{target_compatible_with}": target_compatible_with,
        },
        False,
    )
