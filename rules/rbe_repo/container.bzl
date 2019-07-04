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

_ROOT_DIR = "/rbe_autoconf"
_PROJECT_REPO_DIR = "project_src"
_REPO_DIR = _ROOT_DIR + "/" + _PROJECT_REPO_DIR
_OUTPUT_DIR = _ROOT_DIR + "/autoconf_out"

_BAZELISK_PATH = _ROOT_DIR + "/bazelisk"
_BAZELISK_RELEASE = "v0.0.8"
_BAZELISK_SHA = "5fced4fec06bf24beb631837fa9497b6698f34041463d9188610dfa7b91f4f8d"

# Creates file "container/run_in_container.sh" which will be copied onto container
# to run the commands to run bazel and create the output tar
def _create_docker_cmd(
        ctx,
        config_repos,
        outputs_tar,
        use_default_project):
    # Set permissions on bazelisk
    bazelisk_cmd = "chmod +x " + _BAZELISK_PATH

    # Command to recursively convert soft links to hard links in the config_repos
    # Needed because some outputs of local_cc_config (e.g., dummy_toolchain.bzl)
    # could be symlinks.
    deref_symlinks_cmd = []
    for config_repo in config_repos:
        symlinks_cmd = ("find $(" + _BAZELISK_PATH + " info output_base)/" +
                        _EXTERNAL_FOLDER_PREFIX + config_repo +
                        " -type l -exec bash -c 'ln -f \"$(readlink -m \"$0\")\" \"$0\"' {} \\;")
        deref_symlinks_cmd.append(symlinks_cmd)
    deref_symlinks_cmd = " && ".join(deref_symlinks_cmd)

    # Command to copy produced toolchain configs to a tar at the root
    # of the container.
    copy_cmd = ["mkdir " + _OUTPUT_DIR]
    for config_repo in config_repos:
        src_dir = "$(" + _BAZELISK_PATH + " info output_base)/" + _EXTERNAL_FOLDER_PREFIX + config_repo
        copy_cmd.append("cp -dr " + src_dir + " " + _OUTPUT_DIR)
    copy_cmd.append("tar -cf /" + outputs_tar + " -C " + _OUTPUT_DIR + "/ . ")
    output_copy_cmd = " && ".join(copy_cmd)

    # A success command to run after the output_copy_cmd finished.
    # the contents of this echo line are checked for in extract.sh.tpl
    success_echo_cmd = "echo 'created outputs_tar'"

    # if use_default_project was selected, we need to modify the WORKSPACE and BUILD file
    setup_default_project_cmd = ["cd ."]
    if use_default_project:
        setup_default_project_cmd += ["cd " + _ROOT_DIR + "/" + _PROJECT_REPO_DIR]
        setup_default_project_cmd += ["mv BUILD.sample BUILD"]
        setup_default_project_cmd += ["touch WORKSPACE"]

    bazel_cmd = "cd " + _ROOT_DIR + "/" + _PROJECT_REPO_DIR

    # For each config repo we run the target @<config_repo>//...
    bazel_targets = "@" + "//... @".join(config_repos) + "//..."
    bazel_cmd += " && " + _BAZELISK_PATH + " build " + bazel_targets

    # Command to run to clean up after autoconfiguration.
    # we start with "cd ." to make sure in case of failure everything after the
    # ";" will be executed
    clean_cmd = "cd . ; bazel clean"
    if use_default_project:
        clean_cmd += "; rm WORKSPACE ; mv BUILD BUILD.sample"

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
        result = ctx.execute(["./get_java_home.sh"])
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

    # Download bazelisk
    bazelisk_url = "https://github.com/bazelbuild/bazelisk/releases/download/%s/bazelisk-linux-amd64" % _BAZELISK_RELEASE
    ctx.download(bazelisk_url, "bazelisk", _BAZELISK_SHA)

    # Create the docker run flags to set env vars
    docker_run_flags = []
    for env in ctx.attr.env:
        docker_run_flags += ["--env", env + "=" + ctx.attr.env[env]]
    bazel_version_string = bazel_version
    if bazel_rc_version:
        bazel_version_string += "rc" + str(bazel_rc_version)

    # Set the Bazel version that Bazelisk will use
    docker_run_flags += ["--env", ("USE_BAZEL_VERSION=%s" % bazel_version_string)]

    # Command to copy resources used for rbe_autoconfig to the container.
    copy_data_cmd = []

    # Command to clean up the data volume container.
    clean_data_volume_cmd = ""
    copy_data_cmd.append("data_volume=$(docker create -v " + _ROOT_DIR + " " + image_name + ")")
    copy_data_cmd.append(docker_tool_path + " cp $(realpath " + project_root + ") $data_volume:" + _REPO_DIR)
    copy_data_cmd.append(docker_tool_path + " cp " + str(ctx.path("container")) + " $data_volume:" + _ROOT_DIR + "/container")
    copy_data_cmd.append(docker_tool_path + " cp " + str(ctx.path("bazelisk")) + " $data_volume:" + _BAZELISK_PATH)
    docker_run_flags += ["--volumes-from", "$data_volume"]
    clean_data_volume_cmd = docker_tool_path + " rm $data_volume"

    # Create the template to run
    template = ctx.path(Label("@bazel_toolchains//rules/rbe_repo:extract.sh.tpl"))
    ctx.template(
        "run_and_extract.sh",
        template,
        {
            "%{clean_data_volume_cmd}": clean_data_volume_cmd,
            "%{commands}": _ROOT_DIR + "/container/run_in_container.sh",
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
    result = ctx.execute(["./run_and_extract.sh"])
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
