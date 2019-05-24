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

# Creates file "container/run_in_container.sh" which can be mounted onto container
# to run the commands to install bazel, run it and create the output tar
def _create_docker_cmd(
        ctx,
        config_repos,
        bazel_version,
        bazel_rc_version,
        outputs_tar,
        use_default_project):
    # Command to install Bazel version
    # If a specific Bazel and Bazel RC version is specified, install that version.
    bazel_url = "https://releases.bazel.build/" + bazel_version
    if bazel_rc_version:
        bazel_url += ("/rc" + str(bazel_rc_version) +
                      "/bazel-" + bazel_version + "rc" +
                      str(bazel_rc_version))
    else:
        bazel_url += "/release/bazel-" + bazel_version
    bazel_url += "-installer-linux-x86_64.sh"
    install_bazel_cmd = ["bazel_url=" + bazel_url]
    install_bazel_cmd += ["mkdir -p /src/bazel"]
    install_bazel_cmd += ["cd /src/bazel/"]
    install_bazel_cmd += ["wget $bazel_url --no-verbose --ca-certificate=/etc/ssl/certs/ca-certificates.crt -O /tmp/bazel-installer.sh"]
    install_bazel_cmd += ["chmod +x /tmp/bazel-installer.sh"]
    install_bazel_cmd += ["/tmp/bazel-installer.sh"]
    install_bazel_cmd += ["rm -f /tmp/bazel-installer.sh"]

    # Command to recursively convert soft links to hard links in the config_repos
    # Needed because some outputs of local_cc_config (e.g., dummy_toolchain.bzl)
    # could be symlinks.
    deref_symlinks_cmd = []
    for config_repo in config_repos:
        symlinks_cmd = ("find $(bazel info output_base)/" +
                        _EXTERNAL_FOLDER_PREFIX + config_repo +
                        " -type l -exec bash -c 'ln -f \"$(readlink -m \"$0\")\" \"$0\"' {} \;")
        deref_symlinks_cmd.append(symlinks_cmd)
    deref_symlinks_cmd = " && ".join(deref_symlinks_cmd)

    # Command to copy produced toolchain configs to a tar at the root
    # of the container.
    copy_cmd = ["mkdir " + _OUTPUT_DIR]
    for config_repo in config_repos:
        src_dir = "$(bazel info output_base)/" + _EXTERNAL_FOLDER_PREFIX + config_repo
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
    bazel_cmd += " && bazel build " + bazel_targets

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
    docker_cmd += install_bazel_cmd
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
    if ctx.attr.tag:
        return True
    if ctx.attr.config_version and not ctx.attr.config_repos:
        return False
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
      project_root: the absolute path to the root of the project
      use_default_project: whether or not to use the default project to generate configs
    """
    outputs_tar = ctx.attr.name + "_out.tar"

    # Create command to run inside docker container
    _create_docker_cmd(
        ctx,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        config_repos = config_repos,
        outputs_tar = outputs_tar,
        use_default_project = use_default_project,
    )

    # Create the docker run flags to set env vars
    docker_run_flags = []
    for env in ctx.attr.env:
        docker_run_flags += ["--env", env + "=" + ctx.attr.env[env]]

    # Command to copy resources used for rbe_autoconfig to the container.
    copy_data_cmd = []

    # Command to clean up the data volume container.
    clean_data_volume_cmd = ""
    if ctx.attr.copy_resources:
        copy_data_cmd.append("data_volume=$(docker create -v " + _ROOT_DIR + " " + image_name + ")")
        copy_data_cmd.append("docker cp $(realpath " + project_root + ") $data_volume:" + _REPO_DIR)
        copy_data_cmd.append("docker cp " + str(ctx.path("container")) + " $data_volume:" + _ROOT_DIR + "/container")
        docker_run_flags += ["--volumes-from", "$data_volume"]
        clean_data_volume_cmd = "docker rm $data_volume"
    else:
        mount_read_only_flag = ":ro"
        if use_default_project:
            # If we use the default project, we need to modify the WORKSPACE
            # and BUILD files, so don't mount read-only
            mount_read_only_flag = ""

        # If the rule is invoked from bazel-toolchains itself, then project_root
        # is a symlink, which can cause mounting issues on GCB.
        target = "$(realpath " + project_root + "):" + _REPO_DIR + mount_read_only_flag
        docker_run_flags += ["-v", target]
        docker_run_flags += ["-v", str(ctx.path("container")) + ":" + _ROOT_DIR + "/container"]

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
