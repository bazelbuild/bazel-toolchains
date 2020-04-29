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
"""Exposes tools for rbe_autoconfig to interact with containers/docker."""

load(
    "//rules/rbe_repo:util.bzl",
    "CC_CONFIG_DIR",
    "print_exec_results",
)

# External folder is set to be deprecated, lets keep it here for easy
# refactoring
# https://github.com/bazelbuild/bazel/issues/1262
_EXTERNAL_FOLDER_PREFIX = "external/"

_BAZELISK_RELEASE = "v1.3.0"
_BAZELISK_FILENAME_LINUX = "bazelisk"
_BAZELISK_SHA_LINUX = "98af93c6781156ff3dd36fa06ba6b6c0a529595abb02c569c99763203f3964cc"
_BAZELISK_FILENAME_WINDOWS = "bazelisk.exe"
_BAZELISK_SHA_WINDOWS = "31fa9fcf250fe64aa3c5c83b69d76e1e9571b316a58bb5c714084495623e38b0"
_PROJECT_REPO_DIR = "project_src"

def _is_windows(ctx):
    return ctx.os.name.lower().find("windows") != -1

def _root_dir(ctx):
    if _is_windows(ctx):
        return "C:/rbe_autoconf"
    else:
        return "/rbe_autoconf"

def _download_bazelisk(ctx):
    bazelisk_url = "https://github.com/bazelbuild/bazelisk/releases/download/%s/bazelisk-" % _BAZELISK_RELEASE
    if _is_windows(ctx):
        bazelisk_url += "windows-amd64.exe"
        bazelisk_filename = "bazelisk" + "/" + _BAZELISK_FILENAME_WINDOWS
        bazelisk_sha = _BAZELISK_SHA_WINDOWS
    else:
        bazelisk_url += "linux-amd64"
        bazelisk_filename = _BAZELISK_FILENAME_WINDOWS
        bazelisk_sha = _BAZELISK_SHA_WINDOWS
    ctx.download(bazelisk_url, bazelisk_filename, bazelisk_sha)

def _bazelisk_path(ctx):
    if _is_windows(ctx):
        return _root_dir(ctx) + "/bazelisk/" + _BAZELISK_FILENAME_WINDOWS
    else:
        return _root_dir(ctx) + "/" + _BAZELISK_FILENAME_WINDOWS

# Creates file "container/run_in_container.sh" which will be copied onto container
# to run the commands to run bazel and create the output tar
def _create_docker_cmd(
        ctx,
        config_repos,
        outputs_tar,
        use_default_project):
    bazelisk_cmd = ""

    if not _is_windows(ctx):
        # Set permissions on bazelisk
        bazelisk_cmd = "chmod +x " + _bazelisk_path(ctx)

    # Command to recursively convert soft links to hard links in the config_repos
    # Needed because some outputs of local_cc_config (e.g., dummy_toolchain.bzl)
    # could be symlinks.
    deref_symlinks_cmd = []
    for config_repo in config_repos:
        # TODO: fix the find command below
        symlinks_cmd = ("/usr/bin/find $(" + _bazelisk_path(ctx) + " info output_base)/" +
                        _EXTERNAL_FOLDER_PREFIX + config_repo +
                        " -type l -exec bash -c 'ln -f \"$(readlink -m \"$0\")\" \"$0\"' {} \\;")
        deref_symlinks_cmd.append(symlinks_cmd)
    deref_symlinks_cmd = " && ".join(deref_symlinks_cmd)

    # Command to copy produced toolchain configs to a tar at the root
    # of the container.
    output_dir = _root_dir(ctx) + "/autoconf_out"
    copy_cmd = ["mkdir " + output_dir]
    for config_repo in config_repos:
        src_dir = "$(" + _bazelisk_path(ctx) + " info output_base)/" + _EXTERNAL_FOLDER_PREFIX + config_repo
        copy_cmd.append("cp -dr " + src_dir + " " + output_dir)
    copy_cmd.append("tar -cf /" + outputs_tar + " -C " + output_dir + "/ . ")
    output_copy_cmd = " && ".join(copy_cmd)

    # A success command to run after the output_copy_cmd finished.
    # the contents of this echo line are checked for in extract.sh.tpl
    success_echo_cmd = "echo 'created outputs_tar'"

    # if use_default_project was selected, we need to modify the WORKSPACE and BUILD file
    setup_default_project_cmd = ["cd ."]

    bazel_cmd = "cd " + _root_dir(ctx) + "/" + _PROJECT_REPO_DIR

    # For each config repo we run the target @<config_repo>//...
    bazel_targets = "@" + "//... @".join(config_repos) + "//..."

    # TODO: the target exclusion below is b/c bazel has a bug, see: https://github.com/bazelbuild/bazel/issues/11101
    # the relevant changes have not made their way to a bazel release yet
    if _is_windows(ctx):
        bazel_targets += " -- -@local_config_cc//:link_dynamic_library"

    bazel_cmd += " && " + _bazelisk_path(ctx) + " build " + bazel_targets

    # Command to run to clean up after autoconfiguration.
    # we start with "cd ." to make sure in case of failure everything after the
    # ";" will be executed
    clean_cmd = "cd . ; bazel clean"

    docker_cmd = [
        "#!/bin/bash",
        "set -ex",
        ctx.attr.setup_cmd,
    ]
    docker_cmd += [bazelisk_cmd]
    docker_cmd += setup_default_project_cmd
    docker_cmd += [
        bazel_cmd,
        deref_symlinks_cmd,
        output_copy_cmd,
        success_echo_cmd,
        clean_cmd,
    ]
    ctx.file("container/run_in_container.sh", "\n".join(docker_cmd), True)

def pull_container_needed(ctx):
    """Returns whether or not pulling a container is needed.

    Args:
      ctx: the Bazel context object.

    Returns:
        Returns true if its necesary to pull a container to generate configs.
    """

    # We don't pull a container if we have found a config_version to use
    # and there was no tag and no request to detect java home
    if ctx.attr.config_version and not ctx.attr.detect_java_home and not ctx.attr.tag:
        return False

    # No need to pull if no cc configs or custom repos were requested and
    # java_home is set
    if not ctx.attr.create_cc_configs and ctx.attr.java_home and not ctx.attr.config_repos:
        return False
    return True

def pull_image(ctx, docker_tool_path, image_name):
    """Pulls an image using 'docker pull'.

    Args:
      ctx: the Bazel context object.
      docker_tool_path: path to the docker binary.
      image_name: name of the image to pull.
    """
    ctx.report_progress("pulling image %s." % image_name)
    result = ctx.execute([docker_tool_path, "pull", image_name])
    print_exec_results("pull image", result, fail_on_error = True)
    ctx.report_progress("image pulled.")

    # Create a dummy file with the image name to enable testing
    # if container was pulled
    ctx.file("image_name", """# Test file created to signal container was pulled
%s""" % image_name, False)

def get_java_home(ctx, docker_tool_path, image_name):
    """Gets the value of java_home.

    Gets the value of java_home either from attr or
    by running docker run image_name printenv JAVA_HOME.

    Args:
      ctx: the Bazel context object.
      docker_tool_path: path to the docker binary.
      image_name: name of the image to pull.

    Returns:
        Returns the java_home.
    """
    if ctx.attr.java_home:
        return ctx.attr.java_home
    elif ctx.attr.detect_java_home:
        # Create the template to run
        template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:get_java_home.sh.tpl"))
        ctx.template(
            "get_java_home.sh",
            template,
            {
                "%{docker_tool_path}": docker_tool_path,
                "%{image_name}": image_name,
            },
            True,
        )

        # run get_java_home.sh
        result = ctx.execute(["bash", "./get_java_home.sh"])
        print_exec_results("get java_home", result, fail_on_error = True)
        java_home = result.stdout.splitlines()[0]
        if java_home == "":
            fail("Could not find JAVA_HOME in the container and one was not " +
                 "passed to rbe_autoconfig rule. JAVA_HOME is required because " +
                 "create_java_configs is set to True")
        return java_home
    elif ctx.attr.export_configs:
        fail(("%s failed: export_configs was set but neither java_home nor " +
              "detect_java_home was set.") % ctx.attr.name)
    else:
        return None

def _generate_sample_cc_project(ctx):
    ctx.file(
        "cc-sample-project/BUILD",
        """package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

filegroup(
    name = "srcs",
    srcs = [
        "BUILD",
        "test.cc",
    ],
)

cc_test(
    name = "test",
    srcs = ["test.cc"],
)
""",
    )
    ctx.file(
        "cc-sample-project/test.cc",
        """#include <iostream>

int main() {
  std::cout << "Hello test!" << std::endl;
  return 0;
}

""",
    )
    ctx.file("cc-sample-project/WORKSPACE", "")

def run_and_extract(
        ctx,
        bazel_version,
        bazel_rc_version,
        config_repos,
        docker_tool_path,
        image_name,
        project_root,
        use_default_project):
    """Runs the container and extracts the toolchain configs.

    Runs the container (creates command to run inside container) and extracts the
    toolchain configs.

    Args:
        ctx: the Bazel context object.
        bazel_version: Version string of the Bazel release.
        bazel_rc_version: The RC version of the Bazel release if the given
          Bazel release is a RC.
        config_repos: Optional. list of additional external repos corresponding to
          configure like repo rules that need to be produced in addition to
          local_config_cc
      docker_tool_path: path to the docker binary.
      image_name: name of the image to pull.
      project_root: the absolute path to the root of the project that will
          be copied to the container
      use_default_project: whether or not to use the default project to generate configs
    """
    outputs_tar = ctx.attr.name + "_out.tar"

    # Create command to run inside docker container
    _create_docker_cmd(
        ctx,
        config_repos = config_repos,
        outputs_tar = outputs_tar,
        use_default_project = use_default_project,
    )

    _download_bazelisk(ctx)

    _generate_sample_cc_project(ctx)

    # Create the docker run flags to set env vars
    docker_run_flags = []
    for env in ctx.attr.env:
        docker_run_flags += ["--env", env + "=" + ctx.attr.env[env]]
    bazel_version_string = bazel_version
    if bazel_rc_version:
        bazel_version_string += "rc" + str(bazel_rc_version)

    # Set the Bazel version that Bazelisk will use
    docker_run_flags += ["--env", ("USE_BAZEL_VERSION=%s" % bazel_version_string)]

    # Run as the root user on Linux and equivalent ContainerAdministrator on Windows for images
    # that have a default USER set in the Dockerfile
    if _is_windows(ctx):
        docker_run_flags += ["--user", "ContainerAdministrator"]
    else:
        docker_run_flags += ["--user", "root"]

    # Command to copy resources used for rbe_autoconfig to the container.
    copy_data_cmd = []

    # Command to clean up the data volume container.
    clean_data_volume_cmd = ""

    # docker cp does not function on Windows as expected when copying into volumes so we use bind
    # mounts instead
    if _is_windows(ctx):
        docker_run_flags += ["-v", str(ctx.path("cc-sample-project")) + ":" + _root_dir(ctx) + "/" + _PROJECT_REPO_DIR]
        docker_run_flags += ["-v", str(ctx.path("container")) + ":" + _root_dir(ctx) + "/container"]
        docker_run_flags += ["-v", str(ctx.path("bazelisk")) + ":" + _root_dir(ctx) + "/bazelisk"]
    else:
        copy_data_cmd.append("data_volume=$(docker -v " + _root_dir(ctx) + " " + image_name + ")")
        copy_data_cmd.append(docker_tool_path + " cp " + str(ctx.path("cc-sample-project")) + " $data_volume:" + _root_dir(ctx) + "/" + _PROJECT_REPO_DIR)
        copy_data_cmd.append(docker_tool_path + " cp " + str(ctx.path("container")) + " $data_volume:" + _root_dir(ctx) + "/container")
        copy_data_cmd.append(docker_tool_path + " cp " + str(ctx.path(_BAZELISK_FILENAME_LINUX)) + " $data_volume:" + _bazelisk_path(ctx))
        docker_run_flags += ["--volumes-from", "$data_volume"]
        clean_data_volume_cmd = docker_tool_path + " rm $data_volume"

    # Create the template to run
    template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:extract.sh.tpl"))
    ctx.template(
        "run_and_extract.sh",
        template,
        {
            "%{clean_data_volume_cmd}": clean_data_volume_cmd,
            "%{commands}": "bash " + _root_dir(ctx) + "/container/run_in_container.sh",
            "%{copy_data_cmd}": " && ".join(copy_data_cmd),
            "%{docker_run_flags}": " ".join(docker_run_flags),
            "%{docker_tool_path}": docker_tool_path,
            "%{extract_file}": "/" + outputs_tar,
            "%{image_name}": image_name,
            "%{output}": str(ctx.path(".")) + "/output.tar",
        },
        True,
    )

    # run run_and_extract.sh
    ctx.report_progress("running container")
    result = ctx.execute(["bash", "./run_and_extract.sh"])
    print_exec_results("run_and_extract", result, fail_on_error = True)

    # Expand outputs inside this remote repo
    result = ctx.execute(["tar", "-xf", "output.tar"])
    print_exec_results("expand_tar", result)

    result = ctx.execute(["mv", "./local_config_cc", ("./%s" % CC_CONFIG_DIR)])
    print_exec_results("move local_config_cc files", result)
    result = ctx.execute(["rm", ("./%s/WORKSPACE" % CC_CONFIG_DIR)])
    print_exec_results("clean local_config_cc WORKSPACE", result)
    result = ctx.execute(["rm", ("./%s/tools" % CC_CONFIG_DIR), "-drf"])
    print_exec_results("clean tools in local_config_cc", result)
