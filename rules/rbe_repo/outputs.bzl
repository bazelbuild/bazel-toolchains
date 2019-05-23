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

def expand_outputs(ctx, bazel_version, project_root):
    """
    Copies all outputs of the autoconfig rule to a directory in the project.

    Also deletes the artifacts from the repo directory as they are only
    meant to be used from the output_base.

    Args:
        ctx: The Bazel context.
        bazel_version: The Bazel version string.
        project_root: The output directory where configs will be copied to.
    """
    if ctx.attr.output_base:
        ctx.report_progress("copying outputs to project directory")
        dest = project_root + "/" + ctx.attr.output_base + "/bazel_" + bazel_version + "/"
        if ctx.attr.config_dir:
            dest += ctx.attr.config_dir + "/"
        platform_dest = dest + PLATFORM_DIR + "/"
        java_dest = dest + JAVA_CONFIG_DIR + "/"
        cc_dest = dest + CC_CONFIG_DIR + "/"

        # Create the directories
        result = ctx.execute(["mkdir", "-p", platform_dest])
        print_exec_results("create platform output dir", result)

        # Copy the local_config_cc files to dest/{CC_CONFIG_DIR}/
        if ctx.attr.create_cc_configs:
            result = ctx.execute(["mkdir", "-p", cc_dest])
            print_exec_results("create cc output dir", result)

            # Get the files that were created in the CC_CONFIG_DIR
            ctx.file("local_config_files.sh", ("echo $(find ./%s -type f | sort -n)" % CC_CONFIG_DIR), True)
            result = ctx.execute(["./local_config_files.sh"])
            print_exec_results("resolve autoconf files", result)
            autoconf_files = result.stdout.splitlines()[0].split(" ")
            args = ["cp"] + autoconf_files + [cc_dest]
            result = ctx.execute(args)
            print_exec_results("copy local_config_cc outputs", result, True, args)
            args = ["rm"] + autoconf_files
            result = ctx.execute(args)
            print_exec_results("remove local_config_cc outputs from repo dir", result, True, args)

        # Copy the dest/{JAVA_CONFIG_DIR}/BUILD file
        if ctx.attr.create_java_configs:
            result = ctx.execute(["mkdir", "-p", java_dest])
            print_exec_results("create java output dir", result)
            args = ["cp", str(ctx.path(JAVA_CONFIG_DIR + "/BUILD")), java_dest]
            result = ctx.execute(args)
            print_exec_results("copy java_runtime BUILD", result, True, args)
            args = ["rm", str(ctx.path(JAVA_CONFIG_DIR + "/BUILD"))]
            result = ctx.execute(args)
            print_exec_results("remove java_runtime BUILD from repo dir", result, True, args)

        # Copy the dest/{PLATFORM_DIR}/BUILD file
        args = ["cp", str(ctx.path(PLATFORM_DIR + "/BUILD")), platform_dest]
        result = ctx.execute(args)
        print_exec_results("copy platform BUILD", result, True, args)
        args = ["rm", str(ctx.path(PLATFORM_DIR + "/BUILD"))]
        result = ctx.execute(args)
        print_exec_results("Remove platform BUILD from repo dir", result, True, args)

        # Copy any additional external repos that were requested
        if ctx.attr.config_repos:
            for repo in ctx.attr.config_repos:
                args = ["bash", "-c", "cp -r %s %s" % (repo, dest)]
                result = ctx.execute(args)
                print_exec_results("copy %s repo files" % repo, result, True, args)
                args = ["rm", "-dr", "./%s" % repo]
                result = ctx.execute(args)
                print_exec_results("Remove %s repo files from repo dir" % repo, result, True, args)

        dest_target = ctx.attr.output_base + "/bazel_" + bazel_version
        if ctx.attr.config_dir:
            dest_target += ctx.attr.config_dir + "/"
        template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:.latest.bazelrc.tpl"))
        ctx.template(
            ".latest.bazelrc",
            template,
            {
                "%{dest_target}": dest_target,
            },
            False,
        )
        args = ["mv", str(ctx.path("./.latest.bazelrc")), project_root + "/" + ctx.attr.output_base + "/"]
        result = ctx.execute(args)
        print_exec_results("Move .latest.bazelrc file to outputs", result, True, args)

        # TODO(ngiraldo): Generate new BUILD files that point to checked in configs
        # Create an empty BUILD file so the repo can be built
        ctx.file("BUILD", "", False)
