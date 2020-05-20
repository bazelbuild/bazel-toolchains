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
"""Utils to process outputs to output_base in rbe_autoconf."""

load(
    "//rules/rbe_repo:util.bzl",
    "CC_CONFIG_DIR",
    "JAVA_CONFIG_DIR",
    "PLATFORM_DIR",
    "print_exec_results",
)
load(
    "//rules/rbe_repo:toolchain_config_suite_spec.bzl",
    "string_lists_to_config",
)

def expand_outputs(ctx, bazel_version, project_root, toolchain_config_spec_name):
    """Copies all outputs of the autoconfig rule to a directory in the project.

    Also deletes the artifacts from the repo directory as they are only
    meant to be used from the output_base.

    Args:
        ctx: The Bazel context.
        bazel_version: The Bazel version string.
        project_root: The output directory where configs will be copied to.
        toolchain_config_spec_name: provided/selected name for the toolchain config spec
    """
    ctx.report_progress("copying outputs to project directory")
    dest = project_root + "/" + ctx.attr.toolchain_config_suite_spec["output_base"]
    if toolchain_config_spec_name:
        dest += "/" + toolchain_config_spec_name
    dest += "/bazel_" + bazel_version + "/"
    platform_dest = dest + PLATFORM_DIR + "/"
    java_dest = dest + JAVA_CONFIG_DIR + "/"
    cc_dest = dest + CC_CONFIG_DIR + "/"

    # Create the directories
    result = ctx.execute(["mkdir", "-p", platform_dest])
    print_exec_results("create platform output dir", result)

    files_to_clean = []

    # Copy the local_config_cc files to dest/{CC_CONFIG_DIR}/
    if ctx.attr.create_cc_configs:
        result = ctx.execute(["mkdir", "-p", cc_dest])
        print_exec_results("create cc output dir", result)

        # Get the files that were created in the CC_CONFIG_DIR
        cc_conf_files = _get_cc_conf_files(ctx)
        files_to_clean += cc_conf_files
        args = ["cp"] + cc_conf_files + [cc_dest]
        result = ctx.execute(args)
        print_exec_results("copy local_config_cc outputs", result, True, args)

    # Copy the dest/{JAVA_CONFIG_DIR}/BUILD file
    if ctx.attr.create_java_configs:
        result = ctx.execute(["mkdir", "-p", java_dest])
        print_exec_results("create java output dir", result)
        args = ["cp", str(ctx.path(JAVA_CONFIG_DIR + "/BUILD")), java_dest]
        result = ctx.execute(args)
        print_exec_results("copy java_runtime BUILD", result, True, args)

    # Copy the dest/{PLATFORM_DIR}/BUILD file
    args = ["cp", str(ctx.path(PLATFORM_DIR + "/BUILD")), platform_dest]
    result = ctx.execute(args)
    print_exec_results("copy platform BUILD", result, True, args)
    files_to_clean += ["./" + PLATFORM_DIR + "/BUILD"]

    # Copy any additional external repos that were requested
    if ctx.attr.config_repos:
        for repo in ctx.attr.config_repos:
            args = ["bash", "-c", "cp -r %s %s" % (repo, dest)]
            result = ctx.execute(args)
            print_exec_results("copy %s repo files" % repo, result, True, args)
            files_to_clean += ["./" + repo + "/*"]

    # Delete the outputs
    args = ["bash", "-c", "rm -dr " + " ".join(files_to_clean)]
    result = ctx.execute(args)
    print_exec_results("Remove generated files from repo dir", result, True, args)

    dest_target = ctx.attr.toolchain_config_suite_spec["output_base"]
    if toolchain_config_spec_name:
        dest_target += "/" + toolchain_config_spec_name
    dest_target += "/bazel_" + bazel_version
    template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:.latest.bazelrc.tpl"))
    ctx.template(
        ".latest.bazelrc",
        template,
        {
            "%{dest_target}": dest_target,
        },
        False,
    )
    args = ["mv", str(ctx.path("./.latest.bazelrc")), project_root + "/" + ctx.attr.toolchain_config_suite_spec["output_base"] + "/"]
    result = ctx.execute(args)
    print_exec_results("Move .latest.bazelrc file to outputs", result, True, args)

    # Create an empty BUILD file so the repo can be built
    ctx.file("BUILD", """package(default_visibility = ["//visibility:public"])""", False)

def create_configs_tar(ctx):
    """Copies all outputs of the autoconfig rule to a tar file.

    Produces an configs.tar file at the root of the external repo with all contents.

    Args:
        ctx: The Bazel context.
    """
    files_to_tar = []
    if ctx.attr.create_cc_configs:
        files_to_tar += _get_cc_conf_files(ctx)
    if ctx.attr.create_java_configs:
        files_to_tar += ["./" + JAVA_CONFIG_DIR + "/BUILD"]
    files_to_tar += ["./" + PLATFORM_DIR + "/BUILD"]
    if ctx.attr.config_repos:
        for repo in ctx.attr.config_repos:
            files_to_tar += ["./" + repo + "/*"]

    # Create a tar file with all outputs
    args = ["bash", "-c", "tar -cvf configs.tar " + " ".join(files_to_tar)]
    result = ctx.execute(args)
    print_exec_results("Create configs.tar with all generated files", result, True, args)

    # Create an empty BUILD file so the repo can be built
    ctx.file("BUILD", """package(default_visibility = ["//visibility:public"])
exports_files(["configs.tar"])""", False)

def _get_cc_conf_files(ctx):
    """Gets the paths for all C/C++ toolchain config files

    Args:
        ctx: The Bazel context.

    Returns:
        List with paths to all C/C++ toolchain config files
    """
    cc_conf_files = None
    if ctx.attr.create_cc_configs:
        # Get the files that were created in the CC_CONFIG_DIR
        ctx.file("local_config_files.sh", ("echo $(find ./%s -type f | sort -n)" % CC_CONFIG_DIR), True)
        result = ctx.execute(["bash", "./local_config_files.sh"])
        print_exec_results("resolve autoconf files", result)
        cc_conf_files = result.stdout.splitlines()[0].split(" ")
    return cc_conf_files

def create_versions_file(ctx, toolchain_config_spec_name, digest, java_home, project_root):
    """Creates the versions.bzl file.

    Args:
        ctx: The Bazel context.
        digest: The digest of the container that was pulled to generate configs.
        project_root: The output directory where the versions.bzl file will be copied to.
        toolchain_config_spec_name: provided/selected name for the configs
        java_home: the provided/selected location for java_home
    """

    # un-flatten rbe_repo_configs
    versions_output = ["# Generated file, do not modify by hand"]
    versions_output += ["# Generated by '%s' rbe_autoconfig rule" % ctx.attr.name]
    versions_output += ["\"\"\"Definitions to be used in rbe_repo attr of an rbe_autoconf rule  \"\"\""]
    configs_list = []

    # Create the list of config_repo structs
    configs = string_lists_to_config(ctx, toolchain_config_spec_name, java_home)
    index = 0
    default_toolchain_config_spec = None
    for config in configs:
        if config.name == ctx.attr.toolchain_config_suite_spec["default_toolchain_config_spec"]:
            default_toolchain_config_spec = "toolchain_config_spec%s" % str(index)
        versions_output += ["toolchain_config_spec%s = %s" % (str(index), str(config))]
        configs_list += ["toolchain_config_spec%s" % str(index)]
        index += 1

    # If we did not find one, it probably was not set before, assign
    # it to the first conifg
    if not default_toolchain_config_spec:
        default_toolchain_config_spec = "toolchain_config_spec0"

    # Update the ctx.attr.bazel_to_config_spec_names_map and
    # ctx.attr.container_to_config_spec_names_map with the new generated
    # config info
    bazel_to_config_spec_names_map = ctx.attr.bazel_to_config_spec_names_map
    if ctx.attr.bazel_version not in bazel_to_config_spec_names_map.keys():
        bazel_to_config_spec_names_map = dict(ctx.attr.bazel_to_config_spec_names_map)
        bazel_to_config_spec_names_map.update({ctx.attr.bazel_version: [toolchain_config_spec_name]})
    if toolchain_config_spec_name not in bazel_to_config_spec_names_map[ctx.attr.bazel_version]:
        bazel_to_config_spec_names_map = dict(bazel_to_config_spec_names_map.items())
        config_list = bazel_to_config_spec_names_map.pop(ctx.attr.bazel_version) + [toolchain_config_spec_name]
        bazel_to_config_spec_names_map.update({ctx.attr.bazel_version: config_list})
    container_to_config_spec_names_map = ctx.attr.container_to_config_spec_names_map
    if digest not in container_to_config_spec_names_map.keys():
        container_to_config_spec_names_map = dict(ctx.attr.container_to_config_spec_names_map.items())
        container_to_config_spec_names_map.update({digest: [toolchain_config_spec_name]})
    elif toolchain_config_spec_name not in container_to_config_spec_names_map[digest]:
        configs = container_to_config_spec_names_map[digest]
        container_to_config_spec_names_map = dict(ctx.attr.container_to_config_spec_names_map.items())
        container_to_config_spec_names_map.update({digest: configs + [toolchain_config_spec_name]})
    versions_output += ["_TOOLCHAIN_CONFIG_SPECS = [%s]" % ",".join(configs_list)]
    versions_output += ["_BAZEL_TO_CONFIG_SPEC_NAMES = %s" % bazel_to_config_spec_names_map]
    versions_output += ["LATEST = \"%s\"" % digest]
    versions_output += ["CONTAINER_TO_CONFIG_SPEC_NAMES = %s" % container_to_config_spec_names_map]
    versions_output += ["_DEFAULT_TOOLCHAIN_CONFIG_SPEC = %s" % default_toolchain_config_spec]
    versions_output += ["TOOLCHAIN_CONFIG_AUTOGEN_SPEC = struct("]
    versions_output += ["        bazel_to_config_spec_names_map = _BAZEL_TO_CONFIG_SPEC_NAMES,"]
    versions_output += ["        container_to_config_spec_names_map = CONTAINER_TO_CONFIG_SPEC_NAMES,"]
    versions_output += ["        default_toolchain_config_spec = _DEFAULT_TOOLCHAIN_CONFIG_SPEC,"]
    versions_output += ["        latest_container = LATEST,"]
    versions_output += ["        toolchain_config_specs = _TOOLCHAIN_CONFIG_SPECS,"]
    versions_output += ["    )"]

    ctx.file("versions.bzl", "\n".join(versions_output), False)

    # Export the versions file (if requested)
    result = ctx.execute(["mkdir", "-p", project_root + "/" + ctx.attr.toolchain_config_suite_spec["output_base"] + "/"])
    print_exec_results("create output_base output dir", result)
    args = ["mv", str(ctx.path("versions.bzl")), project_root + "/" + ctx.attr.toolchain_config_suite_spec["output_base"] + "/"]
    result = ctx.execute(args)
    print_exec_results("Move generated versions.bzl to output_base", result, True, args)
