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

There are two modes of using this repo rules:
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
    RBE_UBUNTU16_04_LATEST = "LATEST",
)
load("//rules:environments.bzl", "clang_env")
load(
    "//rules/rbe_repo:build_gen.bzl",
    "create_java_runtime",
    "create_platform",
    "use_standard_config",
)
load(
    "//rules/rbe_repo:checked_in.bzl",
    "CHECKED_IN_CONFS_FORCE",
    "CHECKED_IN_CONFS_TRY",
    "CHECKED_IN_CONFS_VALUES",
    "RBE_UBUNTU_REGISTRY",
    "RBE_UBUNTU_REPO",
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
    "expand_outputs",
)
load(
    "//rules/rbe_repo:rbe_repo_spec.bzl",
    "config_to_string_lists",
    "validate_rbe_repo_spec",
    rbe_default_repo = "default_rbe_repo_spec",
)
load(
    "//rules/rbe_repo:util.bzl",
    "AUTOCONF_ROOT",
    "DOCKER_PATH",
    "copy_to_test_dir",
    "print_exec_results",
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
    project_root, use_default_project = resolve_project_root(ctx)

    # Check if pulling a container will be needed and pull it if so
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
            print("Image with given tag `%s` is resolved to %s" %
                  (ctx.attr.tag, image_name))

    # Create a default BUILD file with the platform + toolchain targets that
    # will work with RBE with the produced toolchain
    ctx.report_progress("creating platform")
    create_platform(
        ctx,
        # Use "marketplace.gcr.io" instead of "l.gcr.io" in platform targets.
        image_name = image_name.replace("l.gcr.io", "marketplace.gcr.io"),
        name = name,
    )

    # If user picks rbe-ubuntu 16_04 container and
    # a config exists for the current version of Bazel, create aliases and return
    if ctx.attr.config_version and not ctx.attr.config_repos:
        use_standard_config(ctx)

        # Copy all outputs to the test directory
        if ctx.attr.create_testdata:
            copy_to_test_dir(ctx)
        return

    # Get the value of JAVA_HOME to set in the produced
    # java_runtime
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

    ctx.report_progress("expanding outputs")

    # Expand outputs to project dir if user requested it
    if ctx.attr.output_base:
        expand_outputs(
            ctx,
            bazel_version = ctx.attr.bazel_version,
            project_root = project_root,
        )

    # TODO(nlopezgi): refactor call to _copy_to_test_dir
    # so that its not needed to be duplicated here and
    # above.
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
            default = RBE_UBUNTU_REGISTRY,
            doc = ("Optional. The registry to pull the container from. For example, " +
                   "marketplace.gcr.io. The default is the value for rbe-ubuntu16-04 image."),
        ),
        "repository": attr.string(
            default = RBE_UBUNTU_REPO,
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
    if not use_checked_in_confs in CHECKED_IN_CONFS_VALUES:
        fail("use_checked_in_confs must be one of %s." % CHECKED_IN_CONFS_VALUES)
    if not output_base and config_dir:
        fail("config_dir can only be used when output_base is set.")

    if bazel_rc_version and not bazel_version:
        fail("bazel_rc_version can only be used with bazel_version.")

    if not create_java_configs and java_home != None:
        fail("java_home should not be set when create_java_configs is false.")

    # This is a temporary call to verify the default rbe_repo stucture.
    # Will be removed as part of https://github.com/bazelbuild/bazel-toolchains/pull/526
    # TODO(nlopezgi): remove this
    validate_rbe_repo_spec(name, rbe_default_repo())
    config_to_string_lists(rbe_default_repo()["rbe_repo_gen_spec"].toolchain_config_specs())

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
        repository = RBE_UBUNTU_REPO
        registry = RBE_UBUNTU_REGISTRY
        digest = RBE_UBUNTU16_04_LATEST

    if ((registry and registry == RBE_UBUNTU_REGISTRY) and
        (repository and repository == RBE_UBUNTU_REPO)):
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

    if use_checked_in_confs == CHECKED_IN_CONFS_FORCE and not config_version:
        fail(("use_checked_in_confs was set to \"%s\" but no checked-in configs " +
              "were found. Please check your pin to bazel-toolchains is up " +
              "to date, and that you are using a release version of " +
              "Bazel.") % CHECKED_IN_CONFS_FORCE)

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
