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
    "//rules/rbe_repo:repo_confs.bzl",
    "string_lists_to_config",
)

def expand_outputs(ctx, bazel_version, project_root, config_name):
    """Copies all outputs of the autoconfig rule to a directory in the project.

    Produces an output.zip file at the root of the repo with all contents.

    Also deletes the artifacts from the repo directory as they are only
    meant to be used from the output_base.

    Args:
        ctx: The Bazel context.
        bazel_version: The Bazel version string.
        project_root: The output directory where configs will be copied to.
        config_name: provided/selected name for the configs
    """
    ctx.report_progress("copying outputs to project directory")
    dest = project_root + "/" + ctx.attr.rbe_repo["output_base"]
    if config_name:
        dest += "/" + config_name
    dest += "/bazel_" + bazel_version + "/"
    platform_dest = dest + PLATFORM_DIR + "/"
    java_dest = dest + JAVA_CONFIG_DIR + "/"
    cc_dest = dest + CC_CONFIG_DIR + "/"

    # Create the directories
    result = ctx.execute(["mkdir", "-p", platform_dest])
    print_exec_results("create platform output dir", result)

    files_to_tar = []

    # Copy the local_config_cc files to dest/{CC_CONFIG_DIR}/
    if ctx.attr.create_cc_configs:
        result = ctx.execute(["mkdir", "-p", cc_dest])
        print_exec_results("create cc output dir", result)

        # Get the files that were created in the CC_CONFIG_DIR
        ctx.file("local_config_files.sh", ("echo $(find ./%s -type f | sort -n)" % CC_CONFIG_DIR), True)
        result = ctx.execute(["./local_config_files.sh"])
        print_exec_results("resolve autoconf files", result)
        autoconf_files = result.stdout.splitlines()[0].split(" ")
        files_to_tar += autoconf_files
        args = ["cp"] + autoconf_files + [cc_dest]
        result = ctx.execute(args)
        print_exec_results("copy local_config_cc outputs", result, True, args)

    # Copy the dest/{JAVA_CONFIG_DIR}/BUILD file
    if ctx.attr.create_java_configs:
        result = ctx.execute(["mkdir", "-p", java_dest])
        print_exec_results("create java output dir", result)
        args = ["cp", str(ctx.path(JAVA_CONFIG_DIR + "/BUILD")), java_dest]
        files_to_tar += ["./" + JAVA_CONFIG_DIR + "/BUILD"]
        result = ctx.execute(args)
        print_exec_results("copy java_runtime BUILD", result, True, args)

    # Copy the dest/{PLATFORM_DIR}/BUILD file
    args = ["cp", str(ctx.path(PLATFORM_DIR + "/BUILD")), platform_dest]
    result = ctx.execute(args)
    print_exec_results("copy platform BUILD", result, True, args)
    files_to_tar += ["./" + PLATFORM_DIR + "/BUILD"]

    # Copy any additional external repos that were requested
    if ctx.attr.config_repos:
        for repo in ctx.attr.config_repos:
            args = ["bash", "-c", "cp -r %s %s" % (repo, dest)]
            result = ctx.execute(args)
            print_exec_results("copy %s repo files" % repo, result, True, args)
            files_to_tar += ["./" + repo + "/*"]

    # Create a tar file with all outputs and then delete the outputs
    args = ["bash", "-c", "tar -cvf configs.tar " + " ".join(files_to_tar)]
    result = ctx.execute(args)
    print_exec_results("Create configs.tar with all generated files", result, True, args)
    args = ["bash", "-c", "rm -dr " + " ".join(files_to_tar)]
    result = ctx.execute(args)
    print_exec_results("Remove generated files from repo dir", result, True, args)

    dest_target = ctx.attr.rbe_repo["output_base"]
    if config_name:
        dest_target += "/" + config_name
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
    args = ["mv", str(ctx.path("./.latest.bazelrc")), project_root + "/" + ctx.attr.rbe_repo["output_base"] + "/"]
    result = ctx.execute(args)
    print_exec_results("Move .latest.bazelrc file to outputs", result, True, args)

    # Create an empty BUILD file so the repo can be built
    ctx.file("BUILD", """package(default_visibility = ["//visibility:public"])
exports_files(["configs.tar"])""", False)

def create_versions_file(ctx, config_name, digest, java_home, project_root):
    """Creates the versions.bzl file.

    Args:
        ctx: The Bazel context.
        digest: The digest of the container that was pulled to generate configs.
        project_root: The output directory where the versions.bzl file will be copied to.
        config_name: provided/selected name for the configs
        java_home: the provided/selected location for java_home
    """

    # un-flatten rbe_repo_configs
    versions_output = ["# Generated file, do not modify by hand"]
    versions_output += ["# Generated by '%s' rbe_autoconfig rule" % ctx.attr.name]
    versions_output += ["\"\"\"Definitions to be used in rbe_repo attr of an rbe_autoconf rule  \"\"\""]
    configs_list = []

    # Create the list of config_repo structs
    configs = string_lists_to_config(ctx, config_name, java_home)
    index = 0
    default_config = None
    for config in configs:
        if config.name == ctx.attr.rbe_repo["default_config"]:
            default_config = "config%s" % str(index)
        versions_output += ["config%s = %s" % (str(index), str(config))]
        configs_list += ["config%s" % str(index)]
        index += 1

    # If we did not find one, it probably was not set before, assign
    # it to any conifg
    if not default_config:
        default_config = "config0"

    # Update the ctx.attr.bazel_to_config_version_map and
    # ctx.attr.container_to_config_version_map with the new generated
    # config info
    bazel_to_config_version_map = ctx.attr.bazel_to_config_version_map
    if ctx.attr.bazel_version not in bazel_to_config_version_map.keys():
        bazel_to_config_version_map = dict(ctx.attr.bazel_to_config_version_map)
        bazel_to_config_version_map.update({ctx.attr.bazel_version: [config_name]})
    if config_name not in bazel_to_config_version_map[ctx.attr.bazel_version]:
        bazel_to_config_version_map = dict(bazel_to_config_version_map.items())
        config_list = bazel_to_config_version_map.pop(ctx.attr.bazel_version) + [config_name]
        bazel_to_config_version_map.update({ctx.attr.bazel_version: config_list})
    container_to_config_version_map = ctx.attr.container_to_config_version_map
    if digest not in container_to_config_version_map.keys():
        container_to_config_version_map = dict(ctx.attr.container_to_config_version_map.items())
        container_to_config_version_map.update({digest: [config_name]})
    elif config not in container_to_config_version_map[digest]:
        configs = container_to_config_version_map[digest]
        container_to_config_version_map = dict(ctx.attr.container_to_config_version_map.items())
        container_to_config_version_map.update({digest: configs + [config_name]})

    versions_output += ["def configs():"]
    versions_output += ["    return [%s]" % ",".join(configs_list)]
    versions_output += ["def bazel_to_config_versions():"]
    versions_output += ["    return %s" % bazel_to_config_version_map]
    versions_output += ["LATEST = \"%s\"" % digest]
    versions_output += ["def container_to_config_versions():"]
    versions_output += ["    return %s" % container_to_config_version_map]
    versions_output += ["DEFAULT_CONFIG = %s" % default_config]
    versions_output += ["def versions():"]
    versions_output += ["    return struct("]
    versions_output += ["        bazel_to_config_version_map = bazel_to_config_versions,"]
    versions_output += ["        container_to_config_version_map = container_to_config_versions,"]
    versions_output += ["        default_config = DEFAULT_CONFIG,"]
    versions_output += ["        latest_container = LATEST,"]
    versions_output += ["        rbe_repo_configs = configs,"]
    versions_output += ["    )"]

    ctx.file("versions.bzl", "\n".join(versions_output), False)

    # Export the versions file (if requested)
    result = ctx.execute(["mkdir", "-p", project_root + "/" + ctx.attr.rbe_repo["output_base"] + "/"])
    print_exec_results("create output_base output dir", result)
    args = ["mv", str(ctx.path("versions.bzl")), project_root + "/" + ctx.attr.rbe_repo["output_base"] + "/"]
    result = ctx.execute(args)
    print_exec_results("Move generated versions.bzl to output_base", result, True, args)
