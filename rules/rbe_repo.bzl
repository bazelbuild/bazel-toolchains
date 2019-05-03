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

"""Repository Rules to pick/generate toolchain configs for a container image.

The toolchain configs (+ platform) produced/selected by this rule can be used
to, e.g., run a remote build in which remote actions will run inside a
container image.

Exposes the rbe_autoconfig macro that does the following:
- If users selects the standard rbe-ubuntu 16_04 image, create aliases to
  the appropriate toolchain / platform targets for the current version of Bazel
- Otherwise, pull the selected toolchain container image (using 'docker pull').
- Starts up a container using the pulled image, mounting either a small sample
  project or the current project (if output_base is set).
- Installs the current version of Bazel (one currently running) on the container
  (or the one passed in with optional attr). Container must have tools required to install
  and run Bazel (i.e., a jdk, a C/C++ compiler, a python interpreter).
- Runs a bazel command to build the local_config_cc remote repository inside the container.
- Extracts local_config_cc produced files (inside the container) to the produced
  remote repository.
- Produces a default BUILD file with platform and toolchain targets to use the container
  in a remote build.
- Optionally copies the local_config_cc produced files to the project srcs under the
  given output_base directory.

Add to your WORKSPACE file the following:

  load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

  http_archive(
    name = "bazel_toolchains",
    urls = [
      "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/<latest_release>.tar.gz",
      "https://github.com/bazelbuild/bazel-toolchains/archive/<latest_release>.tar.gz",
    ],
    strip_prefix = "bazel-toolchains-<latest_commit>",
    sha256 = "<sha256>",
  )

  load(
    "@bazel_toolchains//repositories:repositories.bzl",
    bazel_toolchains_repositories = "repositories",
  )

  bazel_toolchains_repositories()

  load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig")

  # This is the simplest form of calling rbe_autoconfig.
  # See below other examples, but your WORKSPACE should likely
  # only need one single rbe_autoconfig target
  rbe_autoconfig(
    name = "rbe_default",
  )

  # You can pass an optional output_base if you want the produced
  # toolchain configs to be copied to your source tree (recommended).
  rbe_autoconfig(
    name = "rbe_default_with_output_base",
    output_base = "rbe-configs"
  )

  # If you are using a custom container for remote builds, just
  # set some extra args (see also about env variables)
  rbe_autoconfig(
    name = "rbe_my_custom_container",
    registry = "gcr.io",
    repository = "my-project/my-base",
    # Digest is recommended for any use case other than testing.
    digest = "sha256:deadbeef",
  )

For values of <latest_release> and other placeholders above, please see
the WORKSPACE file in this repo.

This rule depends on the value of the environment variable "RBE_AUTOCONF_ROOT"
when output_base is used.
This env var should be set to point to the absolute path root of your project.
Use the full absolute path to the project root (i.e., no '~', '../', or
other special chars).

There are two modes of using this repo rules:
  1 - When output_base set (recommended if using a custom toolchain container
    image; env var "RBE_AUTOCONF_ROOT" is required), running the repo rule
    target will copy the toolchain config files to the output_base folder in
    the project sources.
    After that, you can run an RBE build pointing your crosstool_top flag to the
    produced files. If output_base is set to "rbe-configs" (recommended):

      bazel build ... \
                --crosstool_top=//rbe-configs/bazel_{bazel_version}/cc:toolchain \
                --host_javabase=//rbe-configs/bazel_{bazel_version}/java:jdk \
                --javabase=//rbe-configs/bazel_{bazel_version}/java:jdk \
                --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8 \
                --java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8 \
                --extra_execution_platforms=//rbe-configs/bazel_{bazel_version}/config:platform \
                --host_platform=//rbe-configs/bazel_{bazel_version}/config:platform \
                --platforms=//rbe-configs/bazel_{bazel_version}/config:platform \
                --extra_toolchains=//rbe-configs/bazel_{bazel_version}/config:cc-toolchain \
                ... <other rbe flags> <build targets>

    We recommend you check in the code in //rbe-configs/bazel_{bazel_version}
    so that most devs/your CI typically do not need to run this repo rule
    in order to do a remote build (i.e., once files are checked in,
    you do not need to run this rule until there is a new version of Bazel
    you want to support running with, or you need to update your container).

  2 - When output_base is not set (recommended for users of the
    rbe-ubuntu 16_04 images - env var "RBE_AUTOCONF_ROOT" is not required),
    running this rule will create targets in the
    external repository (e.g., rbe_default) which can be used to point your
    flags to:

      bazel build ... \
                --crosstool_top=@rbe_default//cc:toolchain \
                --host_javabase=@rbe_default//java:jdk \
                --javabase=@rbe_default//java:jdk \
                --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8 \
                --java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8 \
                --extra_execution_platforms=@rbe_default//config:platform \
                --host_platform=@rbe_default//config:platform \
                --platforms=@rbe_default//config:platform \
                --extra_toolchains=@rbe_default//config:cc-toolchain \

    Note running bazel clean --expunge_async, or otherwise modifying attrs or
    env variables used by this rule will trigger it to re-execute. Running this
    repo rule can take some time (if you are not using the rbe-ubuntu 16_04 container)
    as it needs to pull a container, run it, and then run some commands inside.
    We recommend you use output_base and check in the produced
    files so you dont need to run this rule with every clean build.

The {bazel_version} above corresponds to the version of bazel installed locally.
Note you can override this version and pass an optional rc # if desired.
Running this rule with a non release version (e.g., built from source) will result in
picking as bazel version _BAZEL_VERSION_FALLBACK. Note the bazel_version / bazel_rc_version
must be published in https://releases.bazel.build/...

Note this is a very not hermetic repository rule that can actually change the
contents of your project sources. While this is generally not recommended by
Bazel, its the only reasonable way to get a rule that can produce valid
toolchains / platforms that need to be made available to Bazel before execution
of any build actions.

Note: this rule expects the following utilities to be installed and available on
the PATH (if any container other than rbe-ubuntu 16_04 is used):
  - docker
  - tar
  - bash utilities (e.g., cp, mv, rm, etc)
  - docker authentication to pull the desired container should be set up
    (rbe-ubuntu16-04 does not require any auth setup currently).

Known limitations (if any container other than rbe-ubuntu 16_04 is used):
  - This rule cannot be executed inside a docker container.
  - This rule can only run in Linux.
"""

load(
    "//configs/dependency-tracking:ubuntu1604.bzl",
    BAZEL_LATEST = "bazel",
)
load(
    "//configs/ubuntu16_04_clang:versions.bzl",
    "bazel_to_config_versions",
    RBE_UBUNTU16_04_LATEST = "LATEST",
    rbe_ubuntu16_04_config_version = "container_to_config_version",
)
load("//rules:environments.bzl", "clang_env")
load(
    "//rules:version_check.bzl",
    "extract_version_number",
    "parse_rc",
)

# Version to fallback to if not provided explicitly and local is non-release version.
_BAZEL_VERSION_FALLBACK = BAZEL_LATEST

# External folder is set to be deprecated, lets keep it here for easy
# refactoring
# https://github.com/bazelbuild/bazel/issues/1262
_EXTERNAL_FOLDER_PREFIX = "external/"

_ROOT_DIR = "/rbe_autoconf"
_CC_TOOLCHAIN = ":cc-compiler-k8"
_CONFIG_REPOS = ["local_config_cc"]
_PLATFORM_DIR = "config"
_PROJECT_REPO_DIR = "project_src"
_OUTPUT_DIR = _ROOT_DIR + "/autoconf_out"
_REPO_DIR = _ROOT_DIR + "/" + _PROJECT_REPO_DIR
_AUTOCONF_ROOT = "RBE_AUTOCONF_ROOT"
_DOCKER_PATH = "DOCKER_PATH"
_CC_CONFIG_DIR = "cc"
_JAVA_CONFIG_DIR = "java"

_RBE_UBUNTU_REPO = "google/rbe-ubuntu16-04"
_RBE_UBUNTU_REGISTRY = "marketplace.gcr.io"
_RBE_UBUNTU_EXEC_COMPAT_WITH = [
    "@bazel_tools//platforms:x86_64",
    "@bazel_tools//platforms:linux",
    "@bazel_tools//tools/cpp:clang",
]
_RBE_UBUNTU_TARGET_COMPAT_WITH = [
    "@bazel_tools//platforms:linux",
    "@bazel_tools//platforms:x86_64",
]
_CHECKED_IN_CONFS_TRY = "Try"
_CHECKED_IN_CONFS_FORCE = "Force"
_CHECKED_IN_CONFS_FALSE = "False"
_CHECKED_IN_CONFS_VALUES = [
    _CHECKED_IN_CONFS_TRY,
    _CHECKED_IN_CONFS_FORCE,
    _CHECKED_IN_CONFS_FALSE,
]
_VERBOSE = False

def _rbe_autoconfig_impl(ctx):
    """Core implementation of _rbe_autoconfig repository rule."""

    bazel_version_debug = "Bazel %s" % ctx.attr.bazel_version
    if ctx.attr.bazel_rc_version:
        bazel_version_debug += " rc%s" % ctx.attr.bazel_rc_version
    print("%s is used in rbe_autoconfig." % bazel_version_debug)

    name = ctx.attr.name
    image_name = None
    if ctx.attr.digest:
        image_name = ctx.attr.registry + "/" + ctx.attr.repository + "@" + ctx.attr.digest
    else:
        image_name = ctx.attr.registry + "/" + ctx.attr.repository + ":" + ctx.attr.tag

    # Use l.gcr.io registry to pull marketplace.gcr.io images to avoid auth
    # issues for users who do not do gcloud login.
    image_name = image_name.replace("marketplace.gcr.io", "l.gcr.io")
    docker_tool_path = None

    # Resolve the project_root
    project_root, use_default_project = _resolve_project_root(ctx)

    # Check if pulling a container will be needed and pull it if so
    if _pull_container_needed(ctx):
        ctx.report_progress("validating host tools")
        docker_tool_path = _validate_host(ctx)

        # Pull the image using 'docker pull'
        _pull_image(ctx, docker_tool_path, image_name)

        # If tag is specified instead of digest, resolve it to digest in the
        # image_name as it will be used later on in the platform targets.
        if ctx.attr.tag:
            result = ctx.execute([docker_tool_path, "inspect", "--format={{index .RepoDigests 0}}", image_name])
            _print_exec_results("Resolve image digest", result, fail_on_error = True)
            image_name = result.stdout.splitlines()[0]
            print("Image with given tag `%s` is resolved to %s" %
                  (ctx.attr.tag, image_name))

    # Create a default BUILD file with the platform + toolchain targets that
    # will work with RBE with the produced toolchain
    ctx.report_progress("creating platform")
    _create_platform(
        ctx,
        # Use "marketplace.gcr.io" instead of "l.gcr.io" in platform targets.
        image_name = image_name.replace("l.gcr.io", "marketplace.gcr.io"),
        name = name,
    )

    # If user picks rbe-ubuntu 16_04 container and
    # a config exists for the current version of Bazel, create aliases and return
    if ctx.attr.config_version and not ctx.attr.config_repos:
        _use_standard_config(ctx)

        # Copy all outputs to the test directory
        if ctx.attr.create_testdata:
            _copy_to_test_dir(ctx)
        return

    # Get the value of JAVA_HOME to set in the produced
    # java_runtime
    if ctx.attr.create_java_configs:
        java_home = _get_java_home(ctx, docker_tool_path, image_name)
        _create_java_runtime(ctx, java_home)

    config_repos = []
    if ctx.attr.create_cc_configs:
        config_repos.extend(_CONFIG_REPOS)
    if ctx.attr.config_repos:
        config_repos.extend(ctx.attr.config_repos)
    if config_repos:
        # run the container and extract the autoconf directory
        _run_and_extract(
            ctx,
            bazel_version = ctx.attr.bazel_version,
            bazel_rc_version = ctx.attr.bazel_rc_version,
            config_repos = config_repos,
            docker_tool_path = docker_tool_path,
            image_name = image_name,
            project_root = project_root,
            use_default_project = use_default_project,
        )

    ctx.report_progress("expanding outputs")

    # Expand outputs to project dir if user requested it
    if ctx.attr.output_base:
        _expand_outputs(
            ctx,
            bazel_version = ctx.attr.bazel_version,
            project_root = project_root,
        )

    # TODO(nlopezgi): refactor call to _copy_to_test_dir
    # so that its not needed to be duplicated here and
    # above.
    # Copy all outputs to the test directory
    if ctx.attr.create_testdata:
        _copy_to_test_dir(ctx)

# Convenience method to print results of execute (and fail on errors if needed).
# Verbose logging is enabled via a global var in this bzl file.
def _print_exec_results(prefix, exec_result, fail_on_error = False, args = None):
    if _VERBOSE and exec_result.return_code != 0:
        print(prefix + "::error::" + exec_result.stderr)
    elif _VERBOSE:
        print(prefix + "::success::" + exec_result.stdout)
    if fail_on_error and exec_result.return_code != 0:
        if _VERBOSE and args:
            print("failed to run execute with the following args:" + str(args))
        fail("Failed to run:" + prefix + ":" + exec_result.stderr)

# Returns the project_root that will be used to copy sources
# to the container (if needed) and whether or not the default cc project
# was selected.
def _resolve_project_root(ctx):
    # If not using checked-in configs and output_base was selected or
    # config_repos were requested we need to resolve the project_root
    # using the env variable
    project_root = None
    use_default_project = None
    if (not ctx.attr.config_version and ctx.attr.output_base) or ctx.attr.config_repos:
        project_root = ctx.os.environ.get(_AUTOCONF_ROOT, None)
        print("RBE_AUTOCONF_ROOT is %s" % project_root)

        # TODO (nlopezgi): validate _AUTOCONF_ROOT points to a valid Bazel project
        use_default_project = False
        if not project_root:
            fail(("%s env variable must be set for rbe_autoconfig" +
                  " to function properly when output_base or config_repos are set") % _AUTOCONF_ROOT)
    elif not ctx.attr.config_version:
        # TODO(nlopezgi): consider using native.existing_rules() to validate
        # bazel_toolchains repo exists.
        # Try to use the default project
        # This is Bazel black magic, we're traversing the directories in the output_base,
        # assuming that the bazel_toolchains external repo will exist in the
        # expected path.
        project_root = ctx.path(".").dirname.get_child("bazel_toolchains").get_child("rules").get_child("cc-sample-project")
        if not project_root.exists:
            fail(("Could not find default autoconf project in %s, please make sure " +
                  "the bazel-toolchains repo is imported in your workspace with name " +
                  "'bazel_toolchains' and imported before the rbe_autoconfig target " +
                  "declaration ") % str(project_root))
        project_root = str(project_root)
        use_default_project = True
    return project_root, use_default_project

# Verifies if we need to pull a container to resolve the configs.
def _pull_container_needed(ctx):
    if ctx.attr.tag:
        return True
    if ctx.attr.config_version and not ctx.attr.config_repos:
        return False
    if not ctx.attr.create_cc_configs and ctx.attr.java_home and not ctx.attr.config_repos:
        return False
    return True

# Perform validations of host environment to be able to run the rule.
# Returns the path to the docker tool binary
def _validate_host(ctx):
    if ctx.os.name.lower() != "linux":
        fail("Not running on linux host, cannot run rbe_autoconfig.")
    docker_tool_path = ctx.os.environ.get(_DOCKER_PATH, None)
    if not docker_tool_path:
        docker_tool_path = ctx.which("docker")
    if not docker_tool_path:
        fail("Cannot run rbe_autoconfig as 'docker' was not found on the " +
             "path and environment variable DOCKER_PATH was not set.")
    result = ctx.execute([docker_tool_path, "ps"])
    if result.return_code != 0:
        fail("Cannot run rbe_autoconfig as running '%s ps' returned a " +
             "non 0 exit code, please check you have permissions to " +
             "run docker. Error message: %s" % docker_tool_path, result.stderr)
    if not ctx.which("tar"):
        fail("Cannot run rbe_autoconfig as 'tar' was not found on the path.")
    print("Found docker tool in %s" % docker_tool_path)
    return str(docker_tool_path)

# Produces BUILD files with alias for the C++/Java toolchain targets.
def _use_standard_config(ctx):
    print("Using checked-in configs.")

    if ctx.attr.create_cc_configs:
        # Create the BUILD file with the alias for the cc_toolchain_suite
        template = ctx.path(Label("@bazel_toolchains//rules:BUILD.cc_alias.tpl"))
        toolchain = ("@bazel_toolchains//configs/ubuntu16_04_clang/{version}/bazel_{bazel_version}/{cc_dir}:toolchain".format(
            version = ctx.attr.config_version,
            bazel_version = ctx.attr.bazel_version,
            cc_dir = _CC_CONFIG_DIR,
        ))
        ctx.template(
            _CC_CONFIG_DIR + "/BUILD",
            template,
            {
                "%{toolchain}": toolchain,
            },
            False,
        )

    if ctx.attr.create_java_configs:
        # Create the BUILD file with the alias for the java_runtime
        template = ctx.path(Label("@bazel_toolchains//rules:BUILD.java_alias.tpl"))
        java_runtime = ("@bazel_toolchains//configs/ubuntu16_04_clang/{version}/bazel_{bazel_version}/{java_dir}:jdk".format(
            version = ctx.attr.config_version,
            bazel_version = ctx.attr.bazel_version,
            java_dir = _JAVA_CONFIG_DIR,
        ))

        ctx.template(
            _JAVA_CONFIG_DIR + "/BUILD",
            template,
            {
                "%{java_runtime}": java_runtime,
            },
            False,
        )

# Pulls an image using 'docker pull'.
def _pull_image(ctx, docker_tool_path, image_name):
    ctx.report_progress("pulling image %s." % image_name)
    result = ctx.execute([docker_tool_path, "pull", image_name])
    _print_exec_results("pull image", result, fail_on_error = True)
    ctx.report_progress("image pulled.")

    # Create a dummy file with the image name to enable testing
    # if container was pulled
    ctx.file("image_name", """# Test file created to signal container was pulled
%s""" % image_name, False)

# Gets the value of java_home either from attr or
# by running docker run image_name printenv JAVA_HOME.
def _get_java_home(ctx, docker_tool_path, image_name):
    if ctx.attr.java_home:
        return ctx.attr.java_home

    # Create the template to run
    template = ctx.path(Label("@bazel_toolchains//rules:get_java_home.sh.tpl"))
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
    _print_exec_results("get java_home", result, fail_on_error = True)
    java_home = result.stdout.splitlines()[0]
    if java_home == "":
        fail("Could not find JAVA_HOME in the container and one was not " +
             "passed to rbe_autoconfig rule. JAVA_HOME is required because " +
             "create_java_configs is set to True")
    return java_home

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

# Runs the container (creates command to run inside container) and extracts the
# toolchain configs.
def _run_and_extract(
        ctx,
        bazel_version,
        bazel_rc_version,
        config_repos,
        docker_tool_path,
        image_name,
        project_root,
        use_default_project):
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
    template = ctx.path(Label("@bazel_toolchains//rules:extract.sh.tpl"))
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
    _print_exec_results("run_and_extract", result, fail_on_error = True)

    # Expand outputs inside this remote repo
    result = ctx.execute(["tar", "-xf", "output.tar"])
    _print_exec_results("expand_tar", result)

    result = ctx.execute(["mv", "./local_config_cc", ("./%s" % _CC_CONFIG_DIR)])
    _print_exec_results("move local_config_cc files", result)
    result = ctx.execute(["rm", ("./%s/WORKSPACE" % _CC_CONFIG_DIR)])
    _print_exec_results("clean local_config_cc WORKSPACE", result)
    result = ctx.execute(["rm", ("./%s/tools" % _CC_CONFIG_DIR), "-drf"])
    _print_exec_results("clean tools in local_config_cc", result)

# Creates a BUILD file with the java_runtime target
def _create_java_runtime(ctx, java_home):
    template = ctx.path(Label("@bazel_toolchains//rules:BUILD.java.tpl"))
    ctx.template(
        _JAVA_CONFIG_DIR + "/BUILD",
        template,
        {
            "%{java_home}": java_home,
        },
        False,
    )

# Creates a BUILD file with the cc_toolchain and platform targets
def _create_platform(ctx, image_name, name):
    cc_toolchain_target = "@" + name + "//" + _CC_CONFIG_DIR + _CC_TOOLCHAIN

    # A checked in config was found
    if ctx.attr.config_version:
        cc_toolchain_target = ("@bazel_toolchains//configs/ubuntu16_04_clang/{version}/bazel_{bazel_version}/{cc_dir}{target}".format(
            version = ctx.attr.config_version,
            bazel_version = ctx.attr.bazel_version,
            cc_dir = _CC_CONFIG_DIR,
            target = _CC_TOOLCHAIN,
        ))
    if ctx.attr.output_base:
        cc_toolchain_target = "//" + ctx.attr.output_base + "/bazel_" + ctx.attr.bazel_version
        if ctx.attr.config_dir:
            cc_toolchain_target += "/" + ctx.attr.config_dir
        cc_toolchain_target += "/cc" + _CC_TOOLCHAIN
    template = ctx.path(Label("@bazel_toolchains//rules:BUILD.platform.tpl"))
    exec_compatible_with = ("\"" +
                            ("\",\n        \"").join(ctx.attr.exec_compatible_with) +
                            "\",")
    target_compatible_with = ("\"" +
                              ("\",\n        \"").join(ctx.attr.target_compatible_with) +
                              "\",")
    ctx.template(
        _PLATFORM_DIR + "/BUILD",
        template,
        {
            "%{cc_toolchain}": cc_toolchain_target,
            "%{exec_compatible_with}": exec_compatible_with,
            "%{image_name}": image_name,
            "%{target_compatible_with}": target_compatible_with,
        },
        False,
    )

def _expand_outputs(ctx, bazel_version, project_root):
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
        platform_dest = dest + _PLATFORM_DIR + "/"
        java_dest = dest + _JAVA_CONFIG_DIR + "/"
        cc_dest = dest + _CC_CONFIG_DIR + "/"

        # Create the directories
        result = ctx.execute(["mkdir", "-p", platform_dest])
        _print_exec_results("create platform output dir", result)

        # Copy the local_config_cc files to dest/{_CC_CONFIG_DIR}/
        if ctx.attr.create_cc_configs:
            result = ctx.execute(["mkdir", "-p", cc_dest])
            _print_exec_results("create cc output dir", result)

            # Get the files that were created in the _CC_CONFIG_DIR
            ctx.file("local_config_files.sh", ("echo $(find ./%s -type f | sort -n)" % _CC_CONFIG_DIR), True)
            result = ctx.execute(["./local_config_files.sh"])
            _print_exec_results("resolve autoconf files", result)
            autoconf_files = result.stdout.splitlines()[0].split(" ")
            args = ["cp"] + autoconf_files + [cc_dest]
            result = ctx.execute(args)
            _print_exec_results("copy local_config_cc outputs", result, True, args)
            args = ["rm"] + autoconf_files
            result = ctx.execute(args)
            _print_exec_results("remove local_config_cc outputs from repo dir", result, True, args)

        # Copy the dest/{_JAVA_CONFIG_DIR}/BUILD file
        if ctx.attr.create_java_configs:
            result = ctx.execute(["mkdir", "-p", java_dest])
            _print_exec_results("create java output dir", result)
            args = ["cp", str(ctx.path(_JAVA_CONFIG_DIR + "/BUILD")), java_dest]
            result = ctx.execute(args)
            _print_exec_results("copy java_runtime BUILD", result, True, args)
            args = ["rm", str(ctx.path(_JAVA_CONFIG_DIR + "/BUILD"))]
            result = ctx.execute(args)
            _print_exec_results("remove java_runtime BUILD from repo dir", result, True, args)

        # Copy the dest/{_PLATFORM_DIR}/BUILD file
        args = ["cp", str(ctx.path(_PLATFORM_DIR + "/BUILD")), platform_dest]
        result = ctx.execute(args)
        _print_exec_results("copy platform BUILD", result, True, args)
        args = ["rm", str(ctx.path(_PLATFORM_DIR + "/BUILD"))]
        result = ctx.execute(args)
        _print_exec_results("Remove platform BUILD from repo dir", result, True, args)

        # Copy any additional external repos that were requested
        if ctx.attr.config_repos:
            for repo in ctx.attr.config_repos:
                args = ["bash", "-c", "cp -r %s %s" % (repo, dest)]
                result = ctx.execute(args)
                _print_exec_results("copy %s repo files" % repo, result, True, args)
                args = ["rm", "-dr", "./%s" % repo]
                result = ctx.execute(args)
                _print_exec_results("Remove %s repo files from repo dir" % repo, result, True, args)

        dest_target = ctx.attr.output_base + "/bazel_" + bazel_version
        if ctx.attr.config_dir:
            dest_target += ctx.attr.config_dir + "/"
        template = ctx.path(Label("@bazel_toolchains//rules:.latest.bazelrc.tpl"))
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
        _print_exec_results("Move .latest.bazelrc file to outputs", result, True, args)

        # TODO(ngiraldo): Generate new BUILD files that point to checked in configs
        # Create an empty BUILD file so the repo can be built
        ctx.file("BUILD", "", False)

# Copies all contents of the external repo to a test directory,
# modifies name of all BUILD files (to enable file_test to operate on them), and
# creates a root BUILD file in test directory with a filegroup that contains
# all files.
def _copy_to_test_dir(ctx):
    # Copy all files to the test directory
    args = ["bash", "-c", "mkdir ./.test && cp -r ./* ./.test && mv ./.test ./test"]
    result = ctx.execute(args)
    _print_exec_results("copy test output files", result, True, args)

    # Rename BUILD files
    ctx.file("rename_build_files.sh", "find ./test -name \"BUILD\" -exec sh -c 'mv \"$1\" \"$(dirname $1)/test.BUILD\"' _ {} \;", True)
    result = ctx.execute(["./rename_build_files.sh"])
    _print_exec_results("Rename BUILD files in test output", result, True, args)

    # create a root BUILD file with a filegroup
    ctx.file("test/BUILD", """package(default_visibility = ["//visibility:public"])
exports_files(["empty"])
filegroup(
    name = "exported_testdata",
    srcs = glob(["**/*"]),
)
""", False)

    # Create an empty file to reference in test.
    # This is needed for tests to reference the location
    # of all test outputs.
    ctx.file("test/empty", "", False)

def rbe_autoconfig_root_impl(ctx):
    """Core implementation of rbe_autoconfig_root repository rule."""
    ctx.file("AUTOCONF_ROOT", ctx.os.environ.get(_AUTOCONF_ROOT, None), False)
    ctx.file("BUILD", """package(default_visibility = ["//visibility:public"])
exports_files(["AUTOCONF_ROOT"])
""", False)

# Private declaration of _rbe_autoconfig repository rule. Do not use this
# rule directly, use rbe_autoconfig macro declared below.
_rbe_autoconfig = repository_rule(
    attrs = {
        "base_container_digest": attr.string(
            doc = ("Optional. If the container to use for the RBE build " +
                   "extends from the rbe-ubuntu16-04 image, you can " +
                   "pass the digest (sha256 sum) of the base container here " +
                   "and this rule will attempt to use checked-in " +
                   "configs if possible." +
                   "The digest (sha256 sum) of the base image. " +
                   "For example, " +
                   "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c" +
                   ", note the digest includes 'sha256:'"),
        ),
        "bazel_rc_version": attr.int(
            doc = ("Optional. An rc version to use. Note an installer for " +
                   "the rc must be available in https://releases.bazel.build."),
        ),
        "bazel_version": attr.string(
            default = "local",
            doc = ("The version of Bazel to use to generate toolchain configs." +
                   "Use only (major, minor, patch), e.g., '0.20.0'."),
        ),
        "config_dir": attr.string(
            doc = ("Optional. Use only if output_base is defined. If you " +
                   "want to create multiple toolchain configs (for the same " +
                   "version of Bazel) you can use this attr to indicate a " +
                   "type of config (e.g., default,  msan). The configs will " +
                   "be generated in a sub-directory when this attr is used."),
        ),
        "config_repos": attr.string_list(
            doc = ("Optional. list of additional external repos corresponding to " +
                   "configure like repo rules that need to be produced in addition to " +
                   "local_config_cc."),
        ),
        "config_version": attr.string(
            doc = ("The config version found for the given container and " +
                   "Bazel version. " +
                   "Used internally when use_checked_in_confs is true."),
        ),
        "copy_resources": attr.bool(
            default = True,
            doc = (
                "Optional. Specifies whether to copy instead of mounting " +
                "resources such as scripts and project source code to the " +
                "container for Bazel autoconfig. Note that copy_resources " +
                "works out of the box when Bazel is run inside " +
                "a docker container. "
            ),
        ),
        "create_cc_configs": attr.bool(
            doc = (
                "Optional. Specifies whether to generate C/C++ configs. " +
                "Defauls to True."
            ),
        ),
        "create_java_configs": attr.bool(
            doc = (
                "Optional. Specifies whether to generate java configs. " +
                "Defauls to True."
            ),
        ),
        "create_testdata": attr.bool(
            doc = (
                "Optional. Specifies whether to generate additional " +
                "testing only outputs. " +
                "Defauls to False."
            ),
        ),
        "digest": attr.string(
            doc = ("Optional. The digest (sha256 sum) of the image to pull. " +
                   "For example, " +
                   "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c" +
                   ", note the digest includes 'sha256:'"),
        ),
        "env": attr.string_dict(
            doc = ("Optional. Dictionary from strings to strings. Additional env " +
                   "variables that will be set when running the Bazel command to " +
                   "generate the toolchain configs."),
        ),
        "exec_compatible_with": attr.string_list(
            default = _RBE_UBUNTU_EXEC_COMPAT_WITH,
            doc = ("Optional. The list of constraints that will be added to the " +
                   "toolchain in its exec_compatible_with attribute (and to " +
                   "the platform in its constraint_values attr). For " +
                   "example, [\"@bazel_tools//platforms:linux\"]. Default " +
                   " is set to values for rbe-ubuntu16-04 container."),
        ),
        "java_home": attr.string(
            doc = ("Optional. The location of java_home in the container. For " +
                   "example , '/usr/lib/jvm/java-8-openjdk-amd64'. Only " +
                   "relevant if 'create_java_configs' is true. If 'create_java_configs' is " +
                   "true and this attribute is not set, the rule will attempt to read the " +
                   "JAVA_HOME env var from the container. If that is not set, the rule " +
                   "will fail."),
        ),
        "output_base": attr.string(
            doc = ("Optional. The directory (under the project root) where the " +
                   "produced toolchain configs will be copied to."),
        ),
        "registry": attr.string(
            default = _RBE_UBUNTU_REGISTRY,
            doc = ("Optional. The registry to pull the container from. For example, " +
                   "marketplace.gcr.io. The default is the value for rbe-ubuntu16-04 image."),
        ),
        "repository": attr.string(
            default = _RBE_UBUNTU_REPO,
            doc = ("Optional. The repository to pull the container from. For example," +
                   " google/ubuntu. The default is the " +
                   " value for the rbe-ubuntu16-04 image."),
        ),
        "setup_cmd": attr.string(
            default = "cd .",
            doc = ("Optional. Pass an additional command that will be executed " +
                   "(inside the container) before running bazel to generate the " +
                   "toolchain configs"),
        ),
        "tag": attr.string(
            doc = ("Optional. The tag of the image to pull, e.g. latest."),
        ),
        "target_compatible_with": attr.string_list(
            default = _RBE_UBUNTU_TARGET_COMPAT_WITH,
            doc = ("The list of constraints that will be added to the " +
                   "toolchain in its target_compatible_with attribute. For " +
                   "example, [\"@bazel_tools//platforms:linux\"]. Default " +
                   " is set to values for rbe-ubuntu16-04 container."),
        ),
    },
    environ = [
        _AUTOCONF_ROOT,
        _DOCKER_PATH,
    ],
    implementation = _rbe_autoconfig_impl,
    local = True,
)

# Rule that exposes the location of _AUTOCONF_ROOT for test
# rules to consume.
rbe_autoconfig_root = repository_rule(
    environ = [
        _AUTOCONF_ROOT,
    ],
    implementation = rbe_autoconfig_root_impl,
    local = True,
)

def rbe_autoconfig(
        name,
        base_container_digest = None,
        bazel_version = None,
        bazel_rc_version = None,
        config_dir = None,
        config_repos = None,
        copy_resources = True,
        create_cc_configs = True,
        create_java_configs = True,
        create_testdata = False,
        digest = None,
        env = None,
        exec_compatible_with = None,
        java_home = None,
        output_base = None,
        tag = None,
        registry = None,
        repository = None,
        target_compatible_with = None,
        use_checked_in_confs = _CHECKED_IN_CONFS_TRY):
    """ Creates a repository with toolchain configs generated for a container image.

    This macro wraps (and simplifies) invocation of _rbe_autoconfig rule.
    Use this macro in your WORKSPACE.

    Args:
      name: Name of the rbe_autoconfig repository target.
      base_container_digest: Optional. If the container to use for the RBE build
          extends from the rbe-ubuntu16-04 image, you can pass the digest
          (sha256 sum) of the base container using this attr.
          The rule will enable use of checked-in configs if possible.
      bazel_version: The version of Bazel to use to generate toolchain configs.
          `Use only (major, minor, patch), e.g., '0.20.0'. Default is "local"
          which means the same version of Bazel that is currently running will
          be used. If local is a non release version, rbe_autoconfig will fallback
          to using the latest release version (see _BAZEL_VERSION_FALLBACK).
      bazel_rc_version: The rc (for the given version of Bazel) to use.
          Must be published in https://releases.bazel.build. E.g. 2.
      config_dir: Optional. Subdirectory where configs will be copied to.
          Use only if output_base is defined.
      config_repos: Optional. list of additional external repos corresponding to
          configure like repo rules that need to be produced in addition to
          local_config_cc
      copy_resources: Optional. Default to True, if set to False, resources
          such as scripts and project source code will be bind mounted onto the
          container instead of copied. This is useful in system where bind mounting
          is enabled and performance is critical.
      create_cc_configs: Optional. Specifies whether to generate C/C++ configs.
          Defauls to True.
      create_java_configs: Optional. Specifies whether to generate java configs.
          Defauls to True.
      create_testdata: Optional. Specifies whether to generate additional testing
          only outputs. Defauls to False.
      digest: Optional. The digest of the image to pull.
          Should not be set if tag is used.
          Must be set together with registry and repository.
      env: dict. Optional. Additional env variables that will be set when
          running the Bazel command to generate the toolchain configs.
          Set to values for marketplace.gcr.io/google/rbe-ubuntu16-04 container.
          Does not need to be set if your custom container extends
          the rbe-ubuntu16-04 container.
          Should be overriden if a custom container does not extend the
          rbe-ubuntu16-04 container.
          Note: Do not pass a custom JAVA_HOME via env, use java_home attr instead.
      exec_compatible_with: Optional. List of constraints to add to the produced
          toolchain/platform targets (e.g., ["@bazel_tools//platforms:linux"] in the
          exec_compatible_with/constraint_values attrs, respectively.
      java_home: Optional. The location of java_home in the container. For
          example , '/usr/lib/jvm/java-8-openjdk-amd64'. Only
          relevant if 'create_java_configs' is true. If 'create_java_configs' is
          true and this attribute is not set, the rule will attempt to read the
          JAVA_HOME env var from the container. If that is not set, the rule
          will fail.
      output_base: Optional. The directory (under the project root) where the
          produced toolchain configs will be copied to.
      tag: Optional. The tag of the container to use.
          Should not be set if digest is used.
          Must be set together with registry and repository.
      registry: Optional. The registry from which to pull the base image.
          Should only be set if a custom container is required.
          Must be set together with digest and repository.
      repository: Optional. he `repository` of images to pull from.
          Should only be set if a custom container is required.
          Must be set together with registry and digest.
      target_compatible_with: List of constraints to add to the produced
          toolchain target (e.g., ["@bazel_tools//platforms:linux"]) in the
          target_compatible_with attr.
      use_checked_in_confs: Default: "Try". Try to look for checked in configs
          before generating them. If set to "False" (string) the rule will
          allways attempt to generate the configs by pulling a toolchain
          container and running Bazel inside. If set to "Force" rule will error
          out if no checked-in configs were found.
    """
    if not use_checked_in_confs in _CHECKED_IN_CONFS_VALUES:
        fail("use_checked_in_confs must be one of %s." % _CHECKED_IN_CONFS_VALUES)
    if not output_base and config_dir:
        fail("config_dir can only be used when output_base is set.")

    if bazel_rc_version and not bazel_version:
        fail("bazel_rc_version can only be used with bazel_version.")

    if not create_java_configs and java_home != None:
        fail("java_home should not be set when create_java_configs is false.")

    # Resolve the Bazel version to use.
    if not bazel_version or bazel_version == "local":
        bazel_version = str(extract_version_number(_BAZEL_VERSION_FALLBACK))
        rc = parse_rc(native.bazel_version)
        bazel_rc_version = rc if rc != -1 else None

    if tag and digest:
        fail("'tag' and 'digest' cannot be set at the same time.")

    if not ((not digest and not tag and not repository and not registry) or
            (digest and repository and registry) or
            (tag and repository and registry)):
        fail("All of 'digest', 'repository' and 'registry' or " +
             "all of 'tag', 'repository' and 'registry' or " +
             "none of them must be set.")

    # Set to defaults only if all are unset.
    if not repository and not registry and not tag and not digest:
        repository = _RBE_UBUNTU_REPO
        registry = _RBE_UBUNTU_REGISTRY
        digest = RBE_UBUNTU16_04_LATEST

    if ((registry and registry == _RBE_UBUNTU_REGISTRY) and
        (repository and repository == _RBE_UBUNTU_REPO)):
        if not env:
            env = clang_env()
        if tag == "latest":
            tag = None
            digest = RBE_UBUNTU16_04_LATEST

    config_version = validateUseOfCheckedInConfigs(
        name = name,
        base_container_digest = base_container_digest,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        create_java_configs = create_java_configs,
        digest = digest,
        env = env,
        java_home = java_home,
        registry = registry,
        repository = repository,
        tag = tag,
        use_checked_in_confs = use_checked_in_confs,
    )

    if use_checked_in_confs == _CHECKED_IN_CONFS_FORCE and not config_version:
        fail(("use_checked_in_confs was set to \"%s\" but no checked-in configs " +
              "were found. Please check your pin to bazel-toolchains is up " +
              "to date, and that you are using a release version of " +
              "Bazel.") % _CHECKED_IN_CONFS_FORCE)

    _rbe_autoconfig(
        name = name,
        base_container_digest = base_container_digest,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        config_dir = config_dir,
        config_repos = config_repos,
        config_version = config_version,
        copy_resources = copy_resources,
        create_cc_configs = create_cc_configs,
        create_java_configs = create_java_configs,
        create_testdata = create_testdata,
        digest = digest,
        env = env,
        exec_compatible_with = exec_compatible_with,
        java_home = java_home,
        output_base = output_base,
        registry = registry,
        repository = repository,
        tag = tag,
        target_compatible_with = target_compatible_with,
    )

def validateUseOfCheckedInConfigs(
        name,
        base_container_digest,
        bazel_version,
        bazel_rc_version,
        create_java_configs,
        digest,
        env,
        java_home,
        registry,
        repository,
        tag,
        use_checked_in_confs):
    """Check if checked-in configs are available and should be used.

    If so, return the config version. Otherwise return None.

    Args:
        name: Name of the rule target.
        base_container_digest: SHA256 sum digest of the base image.
        bazel_version: Version string of the Bazel release.
        bazel_rc_version: The RC version of the Bazel release if the given
                          Bazel release is a RC.
        digest: The digest of the container in which the configs are goings to
                be used.
        env: The environment dict.
        create_java_configs: Whether java config generation is enabled.
        java_home: Path to the Java home.
        registry: The registry where the toolchain container can be found.
        repository: The path to the toolchain container on the registry.
        tag: The tag on the toolchain container.
        use_checked_in_confs: Whether to use checked in configs.

    Returns:
        None
    """
    if use_checked_in_confs == _CHECKED_IN_CONFS_FALSE:
        return None
    if not base_container_digest and registry and registry != _RBE_UBUNTU_REGISTRY:
        return None
    if not base_container_digest and repository and repository != _RBE_UBUNTU_REPO:
        return None
    if env and env != clang_env():
        return None
    if create_java_configs and java_home:
        return None
    if bazel_rc_version:
        return None

    if tag:  # Implies `digest` is not specified.
        if tag == "latest":
            digest = RBE_UBUNTU16_04_LATEST
            # if any tag other than latest is used we will not use checked-in configs
            # (to not hardcode tag info anywhere in these rules)

        else:
            return None

    if base_container_digest:
        digest = base_container_digest

    # Verify a toolchain config exists for the given version of Bazel and the
    # given digest of the container
    config_version = rbe_ubuntu16_04_config_version().get(digest, None)
    if not config_version:
        return None
    if not bazel_to_config_versions().get(bazel_version):
        return None
    for supported_config in bazel_to_config_versions().get(bazel_version):
        if config_version == supported_config:
            return config_version
    return None
