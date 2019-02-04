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
                --crosstool_top=//rbe-configs/bazel_{bazel_version}:toolchain \
                --host_javabase=//rbe-configs/bazel_{bazel_version}/config:jdk \
                --javabase=//rbe-configs/bazel_{bazel_version}/config:jdk \
                --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8 \
                --java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8 \
                --extra_execution_platforms=/rbe-configs/bazel_{bazel_version}/config:platform \
                --host_platform=/rbe-configs/bazel_{bazel_version}/config:platform \
                --platforms=/rbe-configs/bazel_{bazel_version}/config:platform \
                --extra_toolchains=/rbe-configs/bazel_{bazel_version}/config:cc-toolchain \
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
                --crosstool_top=@rbe_default//rbe_config_cc:toolchain \
                --host_javabase=@rbe_default//config:jdk \
                --javabase=@rbe_default//config:jdk \
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
    "//configs/ubuntu16_04_clang:versions.bzl",
    "config_to_bazel_versions",
)
load("//rules:environments.bzl", "clang_env")
load(
    "//rules:toolchain_containers.bzl",
    "RBE_UBUNTU16_04_LATEST",
    "public_rbe_ubuntu16_04_config_version",
    "public_rbe_ubuntu16_04_sha256s",
)
load(
    "//rules:version_check.bzl",
    "extract_version_number",
    "parse_rc",
)

# Version to fallback to if not provided explicitly and local is non-release version.
_BAZEL_VERSION_FALLBACK = "0.22.0"

# External folder is set to be deprecated, lets keep it here for easy
# refactoring
# https://github.com/bazelbuild/bazel/issues/1262
_EXTERNAL_FOLDER_PREFIX = "external/"

_BAZEL_CONFIG_DIR = "/bazel-config"
_CONFIG_REPOS = ["local_config_cc"]
_PLATFORM_DIR = "config"
_PROJECT_REPO_DIR = "project_src"
_OUTPUT_DIR = _BAZEL_CONFIG_DIR + "/autoconf_out"
_REPO_DIR = _BAZEL_CONFIG_DIR + "/" + _PROJECT_REPO_DIR
_RBE_AUTOCONF_ROOT = "RBE_AUTOCONF_ROOT"
_RBE_CONFIG_DIR = "rbe_config_cc"

# We use 'l.gcr.io' to not require users to do gcloud login
_RBE_UBUNTU_REPO = "google/rbe-ubuntu16-04"
_RBE_UBUNTU_REGISTRY = "l.gcr.io"
_RBE_UBUNTU_EXEC_COMPAT_WITH = [
    "@bazel_tools//platforms:x86_64",
    "@bazel_tools//platforms:linux",
    "@bazel_tools//tools/cpp:clang",
]
_RBE_UBUNTU_TARGET_COMPAT_WITH = [
    "@bazel_tools//platforms:linux",
    "@bazel_tools//platforms:x86_64",
]
_VERBOSE = False

def _impl(ctx):
    """Core implementation of _rbe_autoconfig repository rule."""

    # Deal with the simple case first: if user picks rbe-ubuntu 16_04 container and
    # a config exists for the current version of Bazel, just create aliases
    if ctx.attr.use_checked_in_confs:
        if _use_standard_config(ctx, ctx.attr.bazel_version, ctx.attr.bazel_rc_version, ctx.attr.tag):
            # If a standard config was found we are done and can just return.
            return

    # Perform some safety checks
    _validate_host(ctx)
    project_root = ctx.os.environ.get(_RBE_AUTOCONF_ROOT, None)
    use_default_project = False
    if not project_root:
        if ctx.attr.output_base:
            fail(("%s env variable must be set for rbe_autoconfig" +
                  " to function properly when output_base is set") % _RBE_AUTOCONF_ROOT)

        # Try to use the default project
        # This is Bazel black magic, we're traversing the directories in the output_base,
        # assuming that the bazel_toolchains external repo will exist in the
        # expected path.
        project_root = ctx.path(".").dirname.get_child("bazel_toolchains").get_child("rules").get_child("cc-sample-project")
        if not project_root.exists:
            fail(("Could not find default autoconf project in %s, please make sure " +
                  "the bazel-toolchains repo is properly imported in your workspace") % str(project_root))
        project_root = str(project_root)
        use_default_project = True

    name = ctx.attr.name
    outputs_tar = ctx.attr.name + "_out.tar"

    # Pull the image using 'docker pull'
    image_name = None
    if ctx.attr.digest:
        image_name = ctx.attr.registry + "/" + ctx.attr.repository + "@" + ctx.attr.digest
    else:
        image_name = ctx.attr.registry + "/" + ctx.attr.repository + ":" + ctx.attr.tag
    _pull_image(ctx, image_name)

    # If tag is specified instead of digest, resolve it to digest in the
    # image_name as it will be used later on in the platform targets.
    if ctx.attr.tag:
        result = ctx.execute(["docker", "inspect", "--format={{index .RepoDigests 0}}", image_name])
        _print_exec_results("Resolve image digest", result, fail_on_error = True)
        image_name = result.stdout.splitlines()[0]

    # Get the value of JAVA_HOME to set in the produced
    # java_runtime
    java_home = _get_java_home(ctx, image_name)

    # run the container and extract the autoconf directory
    _run_and_extract(
        ctx,
        bazel_version = ctx.attr.bazel_version,
        bazel_rc_version = ctx.attr.bazel_rc_version,
        image_name = image_name,
        outputs_tar = outputs_tar,
        project_root = project_root,
        use_default_project = use_default_project,
    )

    # Create a default BUILD file with the platform + toolchain targets that
    # will work with RBE with the produced toolchain
    _create_platform(
        ctx,
        bazel_version = ctx.attr.bazel_version,
        image_name = image_name,
        java_home = java_home,
        name = name,
    )

    # Expand outputs to project dir if user requested it
    _expand_outputs(
        ctx,
        bazel_version = ctx.attr.bazel_version,
        project_root = project_root,
    )

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

# Perform validations of host environment to be able to run the rule.
def _validate_host(ctx):
    if ctx.os.name.lower() != "linux":
        fail("Not running on linux host, cannot run rbe_autoconfig.")
    if not ctx.which("docker"):
        fail("Cannot run rbe_autoconfig as 'docker' was not found on the path.")
    if ctx.execute(["docker", "ps"]).return_code != 0:
        fail("Cannot run rbe_autoconfig as running 'docker ps' returned a " +
             "non 0 exit code, please check you have permissions to run docker.")
    if not ctx.which("tar"):
        fail("Cannot run rbe_autoconfig as 'tar' was not found on the path.")

# Checks if a standard published config can be used for the given tag
# of the rbe ubuntu 16_04 container. If so, produces BUILD files with aliases
# for all the required toolchain / platform targets. Otherwise returns false.
def _use_standard_config(ctx, bazel_version, bazel_rc_version, tag):
    print("Checked-in configs found. Using checked-in configs.")

    config_version = public_rbe_ubuntu16_04_config_version().get(tag, None)

    # If a config is found, create the BUILD files with the aliases
    template = ctx.path(Label("@bazel_toolchains//rules:BUILD.std_container.tpl"))
    jdk = "@bazel_toolchains//configs/ubuntu16_04_clang/%s:jdk8" % config_version
    cc_toolchain = "@bazel_toolchains//configs/ubuntu16_04_clang/%s/bazel_%s/cpp:cc-toolchain-clang-x86_64-default" % (config_version, bazel_version)
    platform = "@bazel_toolchains//configs/ubuntu16_04_clang/%s:rbe_ubuntu1604" % config_version
    ctx.template(
        _PLATFORM_DIR + "/BUILD",
        template,
        {
            "%{cc-toolchain}": cc_toolchain,
            "%{jdk}": jdk,
            "%{platform}": platform,
        },
        False,
    )

    template = ctx.path(Label("@bazel_toolchains//rules:BUILD.std_toolchain.tpl"))
    toolchain = "@bazel_toolchains//configs/ubuntu16_04_clang/%s/bazel_%s/default:toolchain" % (config_version, bazel_version)
    ctx.template(
        _RBE_CONFIG_DIR + "/BUILD",
        template,
        {
            "%{toolchain}": toolchain,
        },
        False,
    )
    return True

# Pulls an image using 'docker pull'.
def _pull_image(ctx, image_name):
    print("Pulling image %s." % image_name)
    result = ctx.execute(["docker", "pull", image_name])
    _print_exec_results("pull image", result, fail_on_error = True)
    print("Image pulled.")

# Gets the value of java_home either from attr or
# by running docker run image_name printenv JAVA_HOME.
def _get_java_home(ctx, image_name):
    if ctx.attr.java_home:
        return ctx.attr.java_home

    # Create the template to run
    template = ctx.path(Label("@bazel_toolchains//rules:get_java_home.sh.tpl"))
    ctx.template(
        "get_java_home.sh",
        template,
        {
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
             "passed to rbe_autoconfig rule.")
    return java_home

# Creates file "container/run_in_container.sh" which can be mounted onto container
# to run the commands to install bazel, run it and create the output tar
def _create_docker_cmd(
        ctx,
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
    for config_repo in _CONFIG_REPOS:
        symlinks_cmd = ("find $(bazel info output_base)/" +
                        _EXTERNAL_FOLDER_PREFIX + config_repo +
                        " -type l -exec bash -c 'ln -f \"$(readlink -m \"$0\")\" \"$0\"' {} \;")
        deref_symlinks_cmd.append(symlinks_cmd)
    deref_symlinks_cmd = " && ".join(deref_symlinks_cmd)

    # Command to copy produced toolchain configs to a tar at the root
    # of the container.
    copy_cmd = ["mkdir " + _OUTPUT_DIR]
    for config_repo in _CONFIG_REPOS:
        src_dir = "$(bazel info output_base)/" + _EXTERNAL_FOLDER_PREFIX + config_repo
        copy_cmd.append("cp -dr " + src_dir + " " + _OUTPUT_DIR)
    copy_cmd.append("tar -cf /" + outputs_tar + " -C " + _OUTPUT_DIR + "/ . ")
    output_copy_cmd = " && ".join(copy_cmd)

    # if use_default_project was selected, we need to modify the WORKSPACE and BUILD file
    setup_default_project_cmd = ["cd ."]
    if use_default_project:
        setup_default_project_cmd += ["cd " + _BAZEL_CONFIG_DIR + "/" + _PROJECT_REPO_DIR]
        setup_default_project_cmd += ["mv BUILD.sample BUILD"]
        setup_default_project_cmd += ["touch WORKSPACE"]

    bazel_cmd = "cd " + _BAZEL_CONFIG_DIR + "/" + _PROJECT_REPO_DIR

    # For each config repo we run the target @<config_repo>//...
    bazel_targets = "@" + "//... @".join(_CONFIG_REPOS) + "//..."
    bazel_cmd += " && bazel build " + bazel_targets

    # Command to run to clean up after autoconfiguration.
    # we start with "cd ." to make sure in case of failure everything after the
    # ";" will be executed
    clean_cmd = "cd . ; bazel clean"
    if use_default_project:
        clean_cmd += "; rm WORKSPACE ; mv BUILD BUILD.sample"

    docker_cmd = [
        "#!/bin/bash",
        ctx.attr.setup_cmd,
    ]
    docker_cmd += install_bazel_cmd
    docker_cmd += setup_default_project_cmd
    docker_cmd += [
        bazel_cmd,
        deref_symlinks_cmd,
        output_copy_cmd,
        clean_cmd,
    ]
    ctx.file("container/run_in_container.sh", "\n".join(docker_cmd), True)

# Runs the container (creates command to run inside container) and extracts the
# toolchain configs.
def _run_and_extract(
        ctx,
        bazel_version,
        bazel_rc_version,
        image_name,
        outputs_tar,
        project_root,
        use_default_project):
    # Create command to run inside docker container
    _create_docker_cmd(
        ctx,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        outputs_tar = outputs_tar,
        use_default_project = use_default_project,
    )

    # Create the docker run flags to mount the project + install file
    # + set env vars
    docker_run_flags = [""]
    for env in ctx.attr.env:
        docker_run_flags += ["--env", env + "=" + ctx.attr.env[env]]
    mount_read_only_flag = ":ro"
    if use_default_project:
        # If we use the default project, we need to modify the WORKSPACE
        # and BUILD files, so don't mount read-only
        mount_read_only_flag = ""
    target = project_root + ":" + _REPO_DIR + mount_read_only_flag
    docker_run_flags += ["-v", target]
    docker_run_flags += ["-v", str(ctx.path("container")) + ":/container"]

    # Create the template to run
    template = ctx.path(Label("@bazel_toolchains//rules:extract.sh.tpl"))
    ctx.template(
        "run_and_extract.sh",
        template,
        {
            "%{commands}": "/container/run_in_container.sh",
            "%{docker_run_flags}": " ".join(docker_run_flags),
            "%{extract_file}": "/" + outputs_tar,
            "%{image_name}": image_name,
            "%{output}": str(ctx.path(".")) + "/output.tar",
        },
        True,
    )

    # run run_and_extract.sh
    print("Running container")
    result = ctx.execute(["./run_and_extract.sh"])
    _print_exec_results("run_and_extract", result, fail_on_error = True)

    # Expand outputs inside this remote repo
    result = ctx.execute(["tar", "-xf", "output.tar"])
    _print_exec_results("expand_tar", result)
    result = ctx.execute(["mv", "./local_config_cc", ("./%s" % _RBE_CONFIG_DIR)])
    _print_exec_results("expand_tar", result)
    result = ctx.execute(["rm", ("./%s/WORKSPACE" % _RBE_CONFIG_DIR)])
    _print_exec_results("clean WORKSPACE", result)
    result = ctx.execute(["rm", ("./%s/tools" % _RBE_CONFIG_DIR), "-drf"])
    _print_exec_results("clean tools", result)

# Creates a BUILD file with the java and cc toolchain + platform targets
def _create_platform(
        ctx,
        bazel_version,
        image_name,
        java_home,
        name):
    toolchain_target = "@" + name + "//" + _RBE_CONFIG_DIR
    if ctx.attr.output_base:
        toolchain_target = "//" + ctx.attr.output_base + "/bazel_" + bazel_version
        if ctx.attr.config_dir:
            toolchain_target += ctx.attr.config_dir
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
            "%{exec_compatible_with}": exec_compatible_with,
            "%{image_name}": image_name,
            "%{java_home}": java_home,
            "%{target_compatible_with}": target_compatible_with,
            "%{toolchain}": toolchain_target,
        },
        False,
    )

# Copies all outputs of the autoconfig rule to a directory in the project
# sources
def _expand_outputs(ctx, bazel_version, project_root):
    if ctx.attr.output_base:
        print("Copying outputs to project directory")
        dest = project_root + "/" + ctx.attr.output_base + "/bazel_" + bazel_version + "/"
        if ctx.attr.config_dir:
            dest += ctx.attr.config_dir + "/"
        platform_dest = dest + _PLATFORM_DIR + "/"

        # Create the directories
        result = ctx.execute(["mkdir", "-p", "platform_dest"])
        _print_exec_results("create output dir", result)

        # Get the files that were created in the _RBE_CONFIG_DIR
        ctx.file("local_config_files.sh", ("echo $(find ./%s -type f | sort -n)" % _RBE_CONFIG_DIR), True)
        result = ctx.execute(["./local_config_files.sh"])
        _print_exec_results("resolve autoconf files", result)
        autoconf_files = result.stdout.splitlines()[0].split(" ")
        args = ["cp"] + autoconf_files + [dest]

        # Copy the files to dest
        result = ctx.execute(args)
        _print_exec_results("copy outputs", result, True, args)

        # Copy the dest/{_PLATFORM_DIR}/BUILD file
        result = ctx.execute(["cp", str(ctx.path(_PLATFORM_DIR + "/BUILD")), platform_dest])

# Private declaration of _rbe_autoconfig repository rule. Do not use this
# rule directly, use rbe_autoconfig macro declared below.
_rbe_autoconfig = repository_rule(
    attrs = {
        "bazel_rc_version": attr.string(
            doc = ("Optional. An rc version to use. Note an installer for the rc " +
                   "must be available in https://releases.bazel.build."),
        ),
        "bazel_version": attr.string(
            default = "local",
            doc = ("The version of Bazel to use to generate toolchain configs." +
                   "Use only (major, minor, patch), e.g., '0.20.0'."),
        ),
        "config_dir": attr.string(
            doc = ("Optional. Use only if output_base is defined. If you want to " +
                   "create multiple toolchain configs (for the same version of Bazel) " +
                   "you can use this attr to indicate a type of config (e.g., default, " +
                   "msan). The configs will be generated in a sub-directory when this attr  " +
                   "is used."),
        ),
        "digest": attr.string(
            doc = ("The digest (sha256 sum) of the image to pull. For example, " +
                   "sha256:f1330b2f02714d3a3e98c5b1f6524fbb9c15154e44a31fb3caecb7a6ad4e8445" +
                   ", note the digest includes 'sha256:'"),
        ),
        "env": attr.string_dict(
            doc = ("Optional. Dictionary from strings to strings. Additional env " +
                   "variables that will be set when running the Bazel command to " +
                   "generate the toolchain configs."),
        ),
        "exec_compatible_with": attr.string_list(
            default = _RBE_UBUNTU_EXEC_COMPAT_WITH,
            doc = ("The list of constraints that will be added to the " +
                   "toolchain in its exec_compatible_with attribute (and to " +
                   "the platform in its constraint_values attr). For " +
                   "example, [\"@bazel_tools//platforms:linux\"]. Default " +
                   " is set to values for rbe-ubuntu16-04 container."),
        ),
        "java_home": attr.string(
            doc = ("Optional. The location of java_home in the container. " +
                   "For example, '/usr/lib/jvm/java-8-openjdk-amd64'. If " +
                   "not set, the rule will attempt to read the JAVA_HOME env " +
                   "var from the container. If that is not set the rule will " +
                   "fail."),
        ),
        "output_base": attr.string(
            doc = ("Optional. The directory (under the project root) where the " +
                   "produced toolchain configs will be copied to."),
        ),
        "registry": attr.string(
            default = _RBE_UBUNTU_REGISTRY,
            doc = ("The registry to pull the container from. For example, " +
                   "l.gcr.io or marketplace.gcr.io. The default is the " +
                   "value for rbe-ubuntu16-04 image."),
        ),
        "repository": attr.string(
            default = _RBE_UBUNTU_REPO,
            doc = ("The repository to pull the container from. For example," +
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
            doc = ("The tag of the image to pull, e.g. latest."),
        ),
        "target_compatible_with": attr.string_list(
            default = _RBE_UBUNTU_TARGET_COMPAT_WITH,
            doc = ("The list of constraints that will be added to the " +
                   "toolchain in its target_compatible_with attribute. For " +
                   "example, [\"@bazel_tools//platforms:linux\"]. Default " +
                   " is set to values for rbe-ubuntu16-04 container."),
        ),
        "use_checked_in_confs": attr.bool(
            default = True,
            doc = ("If set to False the checked-in configs in bazel-toolchains" +
                   "repo are ignored and a container is allways pulled."),
        ),
    },
    environ = [
        _RBE_AUTOCONF_ROOT,
    ],
    implementation = _impl,
)

def rbe_autoconfig(
        name,
        bazel_version = None,
        bazel_rc_version = None,
        config_dir = None,
        digest = None,
        env = None,
        exec_compatible_with = None,
        java_home = None,
        output_base = None,
        tag = None,
        registry = None,
        repository = None,
        target_compatible_with = None,
        use_checked_in_confs = True):
    """ Creates a repository with toolchain configs generated for a container image.

    This macro wraps (and simplifies) invocation of _rbe_autoconfig rule.
    Use this macro in your WORKSPACE.

    Args:
      bazel_version: The version of Bazel to use to generate toolchain configs.
          `Use only (major, minor, patch), e.g., '0.20.0'. Default is "local"
          which means the same version of Bazel that is currently running will
          be used. If local is a non release version, rbe_autoconfig will fallback
          to using the latest release version (see _BAZEL_VERSION_FALLBACK).
      bazel_rc_version: The rc (for the given version of Bazel) to use. Must be published
          in https://releases.bazel.build. E.g. 2.
      config_dir: Optional. Subdirectory where configs will be copied to.
          Use only if output_base is defined.
      digest: Optional. The digest of the image to pull.
          Should not be set if tag is used.
          Must be set together with registry and repository.
      exec_compatible_with: Optional. List of constraints to add to the produced
          toolchain/platform targets (e.g., ["@bazel_tools//platforms:linux"] in the
          exec_compatible_with/constraint_values attrs, respectively.
      env: dict. Optional. Additional env variables that will be set when
          running the Bazel command to generate the toolchain configs.
          Set to values for gcr.io/cloud-marketplace/google/rbe-ubuntu16-04 container.
          Does not need to be set if your custom container extends
          the rbe-ubuntu16-04 container.
          Should be overriden if a custom container does not extend the
          rbe-ubuntu16-04 container.
      java_home: Optional. The location of java_home in the container. For
          example , '/usr/lib/jvm/java-8-openjdk-amd64'. If not set, the rule
          will attempt to read the JAVA_HOME env var from the container.
          If that is not set the rule will fail.
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
      use_checked_in_confs: Default: True. Try to look for checked in configs
          before generating them. If set to false the rule will allways attempt
          to generate the configs by pulling a toolchain container and running
          Bazel inside.
    """
    if not output_base and config_dir:
        fail("config_dir can only be used when output_base is set.")

    if bazel_rc_version and not bazel_version:
        fail("bazel_rc_version can only be used with bazel_version.")

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

    # Set to defaults only if both are unset.
    if not repository and not registry and not tag and not digest:
        repository = _RBE_UBUNTU_REPO
        registry = _RBE_UBUNTU_REGISTRY
        tag = RBE_UBUNTU16_04_LATEST

    # Check if checked-in configs are available in this repo.
    if registry and registry == _RBE_UBUNTU_REGISTRY and repository and repository == _RBE_UBUNTU_REPO:
        if not env:
            env = clang_env()
        if tag:  # Implies `digest` is not specified.
            if tag == "latest":
                tag = RBE_UBUNTU16_04_LATEST
            digest = public_rbe_ubuntu16_04_sha256s().get(tag, None)
            if not digest:  # We didn't find checked-in configs in this repo.
                use_checked_in_confs = False
        else:  # Implies tag is not specified
            for pair in public_rbe_ubuntu16_04_sha256s().items():
                if pair[1] == digest:
                    tag = pair[0]
                    break
            if not tag:
                use_checked_in_confs = False

        # Verify a toolchain config exists for the given version of Bazel and the
        # given tag of the container
        config_version = public_rbe_ubuntu16_04_config_version().get(tag, None)
        if not config_version:
            use_checked_in_confs = False
        else:
            config_found = False
            for b_v in config_to_bazel_versions().get(config_version):
                if b_v == bazel_version:
                    config_found = True
                    break
            if not config_found:
                use_checked_in_confs = False

    # If the user has set a custom env, custom java_home,
    # registry or repository, don't use
    # checked in configs
    if ((env and env != clang_env()) or
        (java_home) or
        (bazel_rc_version) or
        (registry and registry != _RBE_UBUNTU_REGISTRY) or
        (repository and repository != _RBE_UBUNTU_REPO)):
        use_checked_in_confs = False

    _rbe_autoconfig(
        name = name,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        config_dir = config_dir,
        digest = digest,
        env = env,
        exec_compatible_with = exec_compatible_with,
        java_home = java_home,
        output_base = output_base,
        registry = registry,
        repository = repository,
        tag = tag,
        target_compatible_with = target_compatible_with,
        use_checked_in_confs = use_checked_in_confs,
    )
