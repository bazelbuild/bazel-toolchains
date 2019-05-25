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

This rule depends on the value of the environment variable "RBEAUTOCONF_ROOT"
when output_base is used.
This env var should be set to point to the absolute path root of your project.
Use the full absolute path to the project root (i.e., no '~', '../', or
other special chars).

There are two modes of using this repo rules:# Creates a BUILD file with the java_runtime target
  1 - When output_base set (recommended if using a custom toolchain container
    image; env var "RBEAUTOCONF_ROOT" is required), running the repo rule
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
    rbe-ubuntu 16_04 images - env var "RBEAUTOCONF_ROOT" is not required),
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

Known limitations:
  - This rule can only run in Linux if it needs to generate configs.
"""

load(
    "//configs/dependency-tracking:ubuntu1604.bzl",
    BAZEL_LATEST = "bazel",
)
load(
    "//configs/ubuntu16_04_clang:versions.bzl",
    "bazel_to_config_versions",
    rbe_ubuntu16_04_config_version = "container_to_config_version",
    rbe_ubuntu_repo_configs = "configs",
)
load(
    "//rules/rbe_repo:build_gen.bzl",
    "create_alias_platform",
    "create_config_aliases",
    "create_export_platform",
    "create_external_repo_platform",
    "create_java_runtime",
)
load(
    "//rules/rbe_repo:checked_in.bzl",
    "CHECKED_IN_CONFS_FORCE",
    "CHECKED_IN_CONFS_TRY",
    "CHECKED_IN_CONFS_VALUES",
    "validateUseOfCheckedInConfigs",
)
load(
    "//rules/rbe_repo:container.bzl",
    "get_java_home",
    "pull_container_needed",
    "pull_image",
    "run_and_extract",
)
load(
    "//rules/rbe_repo:outputs.bzl",
    "create_versions_file",
    "expand_outputs",
)
load(
    "//rules/rbe_repo:repo_confs.bzl",
    "config_to_string_lists",
)
load(
    "//rules/rbe_repo:util.bzl",
    "AUTOCONF_ROOT",
    "DOCKER_PATH",
    "copy_to_test_dir",
    "print_exec_results",
    "rbe_default_repo",
    "resolve_project_root",
    "validate_host",
)
load(
    "//rules/rbe_repo:version_check.bzl",
    "extract_version_number",
    "parse_rc",
)

# Version to fallback to if not provided explicitly and local is non-release version.
_BAZEL_VERSION_FALLBACK = BAZEL_LATEST

_CONFIG_REPOS = ["local_config_cc"]

_DEFAULT_CONFIG_NAME = "default_config"

_RBE_UBUNTU_EXEC_COMPAT_WITH = [
    "@bazel_tools//platforms:x86_64",
    "@bazel_tools//platforms:linux",
    "@bazel_tools//tools/cpp:clang",
]
_RBE_UBUNTU_TARGET_COMPAT_WITH = [
    "@bazel_tools//platforms:linux",
    "@bazel_tools//platforms:x86_64",
]

def _rbe_autoconfig_impl(ctx):
    """Core implementation of _rbe_autoconfig repository rule."""

    bazel_version_debug = "Bazel %s" % ctx.attr.bazel_version
    if ctx.attr.bazel_rc_version:
        bazel_version_debug += " rc%s" % ctx.attr.bazel_rc_version
    print("%s is used in %s." % (bazel_version_debug, ctx.attr.name))

    if ctx.attr.use_checked_in_confs == CHECKED_IN_CONFS_FORCE and not ctx.attr.config_version:
        fail(("Target '{name}' failed: use_checked_in_confs was set to '{force}' " +
              "but no checked-in configs were found. " +
              "Please check your pin to '@{rbe_repo_name}' is up " +
              "to date, and that you are using a release version of " +
              "Bazel. You can also explicitly set the version of Bazel to " +
              "an older version in the '{name}' rbe_autoconfig target " +
              "which may or may not work with the version you are currently " +
              "running with.").format(
            name = ctx.attr.name,
            force = CHECKED_IN_CONFS_FORCE,
            rbe_repo_name = ctx.attr.rbe_repo["repo_name"],
        ))

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
    project_root, use_default_project = resolve_project_root(ctx)

    # Check if pulling a container will be needed and pull it if so
    digest = ctx.attr.digest
    if pull_container_needed(ctx):
        ctx.report_progress("validating host tools")
        docker_tool_path = validate_host(ctx)

        # Pull the image using 'docker pull'
        pull_image(ctx, docker_tool_path, image_name)

        # If tag is specified instead of digest, resolve it to digest in the
        # image_name as it will be used later on in the platform targets.
        if ctx.attr.tag:
            result = ctx.execute([docker_tool_path, "inspect", "--format={{index .RepoDigests 0}}", image_name])
            print_exec_results("Resolve image digest", result, fail_on_error = True)
            image_name = result.stdout.splitlines()[0]
            digest = image_name.split("@")[1]
            print("Image with given tag `%s` is resolved to '%s', digest is '%s'" %
                  (ctx.attr.tag, image_name, digest))

    config_name = ctx.attr.config_name
    if ctx.attr.config_version:
        # If we found a config assing that to the config_name so when
        # we produce platform BUILD file we can use it.
        config_name = ctx.attr.config_version
    else:
        # If no config_version was found, generate configs
        # Get the value of JAVA_HOME to set in the produced
        # java_runtime
        java_home = ctx.attr.java_home
        if ctx.attr.create_java_configs:
            java_home = get_java_home(ctx, docker_tool_path, image_name)
            create_java_runtime(ctx, java_home)

        config_repos = []
        if ctx.attr.create_cc_configs:
            config_repos.extend(_CONFIG_REPOS)
        if ctx.attr.config_repos:
            config_repos.extend(ctx.attr.config_repos)
        if config_repos:
            # run the container and extract the autoconf directory
            run_and_extract(
                ctx,
                bazel_version = ctx.attr.bazel_version,
                bazel_rc_version = ctx.attr.bazel_rc_version,
                config_repos = config_repos,
                docker_tool_path = docker_tool_path,
                image_name = image_name,
                project_root = project_root,
                use_default_project = use_default_project,
            )

        if ctx.attr.export_configs:
            ctx.report_progress("expanding outputs")

            # If the user requested exporting configs and did not set a config_name lets pick the default
            # TODO: fix this for when there is no pre-existing default
            if not config_name:
                config_name = ctx.attr.rbe_repo["default_config"]

            # Create a default BUILD file with the platform + toolchain targets that
            # will work with RBE with the produced toolchain (to be exported to
            # output_dir)
            ctx.report_progress("creating output_base platform")
            create_export_platform(
                ctx,
                # Use "marketplace.gcr.io" instead of "l.gcr.io" in platform targets.
                image_name = image_name.replace("l.gcr.io", "marketplace.gcr.io"),
                name = name,
                config_name = config_name,
            )

            # Create the versions.bzl file
            create_versions_file(
                ctx,
                digest = digest,
                config_name = config_name,
                java_home = java_home,
                project_root = project_root,
            )

            # Expand outputs to project dir
            expand_outputs(
                ctx,
                bazel_version = ctx.attr.bazel_version,
                project_root = project_root,
                config_name = config_name,
            )
        else:
            ctx.report_progress("creating external repo platform")
            create_external_repo_platform(
                ctx,
                # Use "marketplace.gcr.io" instead of "l.gcr.io" in platform targets.
                image_name = image_name.replace("l.gcr.io", "marketplace.gcr.io"),
                name = name,
            )

    # If we found checked in confs or if outputs were moved
    # to output_base create the alisases.
    if ctx.attr.config_version or ctx.attr.export_configs:
        create_config_aliases(ctx, config_name)
        create_alias_platform(
            ctx,
            config_name = config_name,
            # Use "marketplace.gcr.io" instead of "l.gcr.io" in platform targets.
            image_name = image_name.replace("l.gcr.io", "marketplace.gcr.io"),
            name = name,
        )

    # Copy all outputs to the test directory
    if ctx.attr.create_testdata:
        copy_to_test_dir(ctx)

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
        # TODO: set defaults / mandatory
        "bazel_to_config_version_map": attr.string_list_dict(
            doc = ("A dict with keys corresponding to lists of bazel versions, " +
                   "values corresponding to configs. SHould point to the " +
                   "bazel_to_config_versions def in the versions.bzl file " +
                   "located in the 'output_base' of the 'rbe_repo'."),
        ),
        "bazel_version": attr.string(
            default = "local",
            doc = ("The version of Bazel to use to generate toolchain configs." +
                   "Use only (major, minor, patch), e.g., '0.20.0'."),
        ),
        "config_name": attr.string(
            doc = ("The name of the config name to be generated."),
        ),
        # TODO: set defaults + mandatory
        "configs_obj_config_repos": attr.string_list(
            doc = ("Set to list 'config_repos' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/repo_confs.bzl."),
        ),
        "configs_obj_create_cc_configs": attr.string_list(
            doc = ("Set to list 'cc_configs' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/repo_confs.bzl."),
        ),
        "configs_obj_create_java_configs": attr.string_list(
            doc = ("Set to list 'java_configs' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/repo_confs.bzl."),
        ),
        "configs_obj_env_keys": attr.string_list(
            doc = ("Set to list 'env_keys' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/repo_confs.bzl."),
        ),
        "configs_obj_env_values": attr.string_list(
            doc = ("Set to list 'env_values' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/repo_confs.bzl."),
        ),
        "configs_obj_java_home": attr.string_list(
            doc = ("Set to list 'java_home' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/repo_confs.bzl."),
        ),
        "configs_obj_names": attr.string_list(
            doc = ("Set to list 'names' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/repo_confs.bzl."),
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
        # TODO: set defaults / mandatory
        "container_to_config_version_map": attr.string_dict(
            doc = ("A dict with keys corresponding to containers and " +
                   "values corresponding to configs. Should point to the " +
                   "container_to_config_version def in the versions.bzl file " +
                   "located in the 'output_base' of the 'rbe_repo'."),
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
        "export_configs": attr.bool(
            doc = (
                "Optional. Specifies whether to copy " +
                "generated configs to the output base. " +
                "Default is False."
            ),
        ),
        "java_home": attr.string(
            doc = ("Optional. The location of java_home in the container. For " +
                   "example , '/usr/lib/jvm/java-8-openjdk-amd64'. Only " +
                   "relevant if 'create_java_configs' is true. If 'create_java_configs' is " +
                   "true and this attribute is not set, the rule will attempt to read the " +
                   "JAVA_HOME env var from the container. If that is not set, the rule " +
                   "will fail."),
        ),
        "registry": attr.string(
            doc = ("Optional. The registry to pull the container from. For example, " +
                   "marketplace.gcr.io. The default is the value for the selected " +
                   "rbe_repo (rbe-ubuntu16-04 image for " +
                   "rbe_default_repo, if no rbe_repo was selected)."),
        ),
        "repository": attr.string(
            doc = ("Optional. The repository to pull the container from. For example, " +
                   "google/ubuntu. The default is the " +
                   "value for the selected rbe_repo (rbe-ubuntu16-04 image for " +
                   "rbe_default_repo, if no rbe_repo was selected)."),
        ),
        "rbe_repo": attr.string_dict(
            doc = ("Mandatory. Dict containing values to identify a " +
                   "toolchain container + GitHub repo where configs are " +
                   "stored. Must include keys: 'repo_name' (name of the " +
                   "external repo, 'output_base' (relative location of " +
                   "the output base in the GitHub repo where configs are " +
                   "located), and 'container_repo', 'container_registry', " +
                   "'container_name' (describing the location of the " +
                   "base toolchain container)"),
            allow_empty = False,
            mandatory = True,
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
        "use_checked_in_confs": attr.string(
            default = CHECKED_IN_CONFS_TRY,
            doc = ("Default: 'Try'. Try to look for checked in configs " +
                   "before generating them. If set to 'False' (string) the " +
                   "rule will allways attempt to generate the configs " +
                   "by pulling a toolchain container and running Bazel inside. " +
                   "If set to 'Force' rule will error out if no checked-in" +
                   "configs were found."),
            values = CHECKED_IN_CONFS_VALUES,
        ),
    },
    environ = [
        AUTOCONF_ROOT,
        DOCKER_PATH,
    ],
    implementation = _rbe_autoconfig_impl,
    local = True,
)

def rbe_autoconfig(
        name,
        base_container_digest = None,
        bazel_version = None,
        bazel_rc_version = None,
        bazel_to_config_version_map = bazel_to_config_versions(),
        config_name = None,
        config_repos = None,
        copy_resources = True,
        container_to_config_version_map = rbe_ubuntu16_04_config_version(),
        create_cc_configs = True,
        create_java_configs = True,
        create_testdata = False,
        digest = None,
        env = None,
        exec_compatible_with = None,
        export_configs = False,
        java_home = None,
        tag = None,
        rbe_repo = rbe_default_repo(),
        rbe_repo_configs = rbe_ubuntu_repo_configs(),
        registry = None,
        repository = None,
        target_compatible_with = None,
        use_checked_in_confs = CHECKED_IN_CONFS_TRY):
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
      # TODO: update this doc after performing validations
      bazel_to_config_version_map: Optional. Set to point by default to using
          map for @bazel_toolchains repo. Only required when export_configs
          is set or using a different repo than @bazel_toolchains.
          Set it to point to def bazel_to_config_versions()
          defined in the versions.bzl file generated in the output_base defined
          in the rbe_repo.
      config_name: Optional. Override default config defined in rbe_repo.
                   Also used for the name of the config to be generated.
      config_repos: Optional. list of additional external repos corresponding to
          configure like repo rules that need to be produced in addition to
          local_config_cc.
      # TODO: update this doc after performing validations
      container_to_config_version_map: Optional. Set to point by default to using
          map for @bazel_toolchains repo.Only required when export_configs
          is set or using a different repo than @bazel_toolchains.
          Set it to point to def container_to_config_versions()
          defined in the versions.bzl file generated in the output_base defined
          in the rbe_repo.
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
      export_configs: Optional, default False. Whether to copy generated configs
          (if they are generated) to the output_base defined in rbe_repo.
      java_home: Optional. The location of java_home in the container. For
          example , '/usr/lib/jvm/java-8-openjdk-amd64'. Only
          relevant if 'create_java_configs' is true. If 'create_java_configs' is
          true and this attribute is not set, the rule will attempt to read the
          JAVA_HOME env var from the container. If that is not set, the rule
          will fail.
      tag: Optional. The tag of the container to use.
          Should not be set if digest is used.
          Must be set together with registry and repository.
      # TODO: update this doc after performing validations
      rbe_repo: Optional. Defaults to using @bazel_toolchains as rbe_repo.
          Should only be set differently if you are using a diferent repo
          as source for your toolchain configs.
          Dict containing values to identify a toolchain
          container + GitHub repo where configs are stored. Must
          include keys:
              'repo_name': name of the Bazel external repo containing
                  configs
              'output_base': relative location of the output base in the
                  GitHub repo where configs are located)
              'container_repo': repo for the base toolchain container
              'container_registry': registry for the base toolchain container
              'latest_container': sha of the latest container
      # TODO: update this doc after performing validations
      rbe_repo_configs: Optional. Set to point by default to using repo
          configs for @bazel_toolchains repo. Only required when export_configs
          is set or using a different repo than @bazel_toolchains.
          Must point to a list containing structs, each struct represents
          a repo config with 'name' (str), 'java_home'(str),
         'create_java_configs' (bool), 'create_cc_configs' (bool),
         'config_repos' (string list) and 'env' (dict).
          defined in the versions.bzl file generated in the output_base defined
          in the rbe_repo.
Must point to configs() in versions.bzl
          generated by this rule. configs() returns a list of structs.
          Each represents a repo config
          with 'name' (str), 'java_home'(str), 'create_java_configs' (bool),
          'create_cc_configs' (bool). 'config_repos' (string list) and
          'env' (dict).
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
    if not use_checked_in_confs in CHECKED_IN_CONFS_VALUES:
        fail("use_checked_in_confs must be one of %s." % CHECKED_IN_CONFS_VALUES)

    if bazel_rc_version and not bazel_version:
        fail("bazel_rc_version can only be used with bazel_version.")

    if not create_java_configs and java_home != None:
        fail("java_home should not be set when create_java_configs is false.")

    # Verify rbe_repo has all required keys
    # 'latest_container' and 'default_config' are optional.
    # TODO: validate this is true.
    required_keys = ["repo_name", "output_base", "container_repo", "container_registry"]
    for key in required_keys:
        if not rbe_repo.get(key):
            fail("rbe_repo in %s does not contain key %s" % (name, key))

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
        repository = rbe_repo["container_repo"]
        registry = rbe_repo["container_registry"]

    config_version, selected_digest = validateUseOfCheckedInConfigs(
        name = name,
        base_container_digest = base_container_digest,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        bazel_to_config_version_map = bazel_to_config_version_map,
        config_repos = config_repos,
        container_to_config_version_map = container_to_config_version_map,
        create_cc_configs = create_cc_configs,
        create_java_configs = create_java_configs,
        digest = digest,
        env = env,
        java_home = java_home,
        rbe_repo = rbe_repo,
        rbe_repo_configs = rbe_repo_configs,
        registry = registry,
        repository = repository,
        requested_config = config_name,
        tag = tag,
        use_checked_in_confs = use_checked_in_confs,
    )

    # If the user selected no digest explicitly, and one was returned
    # by validateUseOfCheckedInConfigs, use that one.
    if not digest and selected_digest:
        digest = selected_digest

    # If using the registry and repo defined in the rbe_repo struct then
    # set the env if its not set (if defined in rbe_repo).
    # Also try to set the digest (preferably to avoid pulling container),
    # default to setting the tag to 'latest'
    if ((registry and registry == rbe_repo["container_registry"]) and
        (repository and repository == rbe_repo["container_repo"])):
        if not env and rbe_repo.get("default_config"):
            env = rbe_repo["default_config"].env
        if tag == "latest" and rbe_repo.get("latest_container"):
            tag = None
            digest = rbe_repo["latest_container"]
        if not digest and not tag and rbe_repo.get("latest_container"):
            digest = rbe_repo["latest_container"]
        if not digest and not tag:
            tag = "latest"

    # Replace the default_config struct for its name, as the rule expects a string dict.
    rbe_repo_cleaned = {
        "default_config": _DEFAULT_CONFIG_NAME if not rbe_repo["default_config"] else rbe_repo["default_config"].name,
        "repo_name": rbe_repo["repo_name"],
        "output_base": rbe_repo["output_base"],
        "container_repo": rbe_repo["container_repo"],
        "container_registry": rbe_repo["container_registry"],
        "latest_container": rbe_repo.get("latest_container"),
    }

    config_objs = struct(
        names = None,
        java_home = None,
        create_java_configs = None,
        create_cc_configs = None,
        config_repos = None,
        env_keys = None,
        env_values = None,
    )
    if export_configs:
        # Flatten rbe_repo_configs structs to pass configs to rule
        config_objs = config_to_string_lists(rbe_repo_configs)

    _rbe_autoconfig(
        name = name,
        base_container_digest = base_container_digest,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        bazel_to_config_version_map = bazel_to_config_version_map,
        config_name = config_name,
        configs_obj_names = config_objs.names,
        configs_obj_java_home = config_objs.java_home,
        configs_obj_create_java_configs = config_objs.create_java_configs,
        configs_obj_create_cc_configs = config_objs.create_cc_configs,
        configs_obj_config_repos = config_objs.config_repos,
        configs_obj_env_keys = config_objs.env_keys,
        configs_obj_env_values = config_objs.env_values,
        config_repos = config_repos,
        config_version = config_version,
        container_to_config_version_map = container_to_config_version_map,
        copy_resources = copy_resources,
        create_cc_configs = create_cc_configs,
        create_java_configs = create_java_configs,
        create_testdata = create_testdata,
        digest = digest,
        env = env,
        exec_compatible_with = exec_compatible_with,
        export_configs = export_configs,
        java_home = java_home,
        rbe_repo = rbe_repo_cleaned,
        registry = registry,
        repository = repository,
        tag = tag,
        target_compatible_with = target_compatible_with,
        use_checked_in_confs = use_checked_in_confs,
    )
