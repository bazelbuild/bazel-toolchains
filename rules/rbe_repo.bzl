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

Exposes the rbe_autoconfig macro that encapsulates all functionality to
create and use toolchain configs. The main use cases for this rule are
  1. If you use the rbe-ubuntu 16_04 image in your RBE builds: This macro
    enables automatic selection of toolchain configs for your RBE build.
    As long as you are using a release version of Bazel and have your pin
    to the bazel-toolchains repo up to date, this rule should "just work"
    to select toolchain configs that have been generated for you before hand.
    More details about the rbe-ubuntu 16_04 image: https://console.cloud.google.com/marketplace/details/google/rbe-ubuntu16-04

  2. If you use a container that extends from the rbe-ubuntu 16_04 image
    in your RBE builds: This macro allows you to define which version of
    the rbe-ubuntu 16_04 image you built yours from, and then it will either
    pick toolchain configs in the bazel-toolchains repo that work for you,
    or will generate them on the fly by pulling the rbe-ubuntu 16_04
    container you used as base and running some commands inside the container.
    The main reason for having to generate a toolchain config (as opposed to
    using one that is checked-in the bazel-toolchains repo) is due to your
    base rbe-ubuntu 16_04 image not being compatible with the latest one,
    for the given version of Bazel you are using.
    If you want to make sure you can use checked-in configs, you should
    rebuild your container, using the latest rbe-ubuntu 16_04 image as base,
    whenever you udpate Bazel versions.

  3. If you use a custom container that does not extend from the rbe-ubuntu 16_04
    image (or your project has custom configure like repo rules, or you
    need to run your configure like repo rules with different environment
    settings):

    3.1. If you don't mind having to generate configs each time you run Bazel from
      a clean client, then this rule can do just that, by simply specifying the
      relevant information about which container to use.

    3.2. If you don't want to generate configs every time, you can use
      rbe_autoconfig to setup a "toolchain_config_repo" from which anyone
      that builds on RBE with your container can pull pre-generated configs from.
      To do this, rbe_autoconfig allows specification of a 'toolchain_config_suite_spec'.
      A 'toolchain_config_suite_spec' specifies all details of an external repo
      that will be used to both export to and read from toolchain configs.
      Details for setting up a "toolchain_config_repo" are below.

    More about configure like repo rules: https://docs.bazel.build/versions/master/remote-execution-rules.html#managing-configure-style-workspace-rules

If rbe_autoconfig needs to generate toolchain configs, the process is as follows:
- Pull the selected toolchain container image (using 'docker pull').
- Start up a container using the pulled image, copying either a small sample
  project or the current project (if output_base is set).
- Install the current version of Bazel (one currently running) on the container
  (or the one passed in with optional attr). Container must have tools required to install
  and run Bazel (i.e., a jdk, a C/C++ compiler, a python interpreter).
- Run a bazel command to build the local_config_cc remote repository inside the container.
- Extract local_config_cc produced files (inside the container) to the produced
  remote repository.
- Produce a default BUILD file with platform and toolchain targets to use the container
  in a remote build.
- Optionally copies the local_config_cc produced files to the project srcs under the
  given output_base directory.

For use case 1. If you use the rbe-ubuntu 16_04 image in your RBE builds,
add to your WORKSPACE file the following:

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
    # If you want your rbe_autoconfig rule to never pull a container
    # and fail fast if toolchain configs are not available, uncomment the
    # following line:
    # use_checked_in_confs = "Force",
  )

For the recommended value of <latest_release> please see
https://releases.bazel.build/bazel-toolchains.html

For use case 2. If you use a container that extends from the rbe-ubuntu 16_04
image, add to your WORKSPACE file the following:

  <Add the bazel-toolchains repo http_archive, same as above>

  rbe_autoconfig(
    name = "rbe_default",
    base_container_digest = <SHA of rbe-ubuntu 16_04 you used as base>
    registry = "gcr.io",
    repository = "your-project/your-image-name",
    # Digest is recommended for any use case other than testing.
    digest = "sha256:deadbeef",
  )

For use case 3.1. If you are using a custom container, and don't mind
having to generate configs each time, add to your WORKSPACE file
the following:

  <Add the bazel-toolchains repo http_archive, same as above>

  rbe_autoconfig(
    name = "rbe_your_custom_container",
    registry = "gcr.io",
    repository = "your-project/your-image-name",
    # Digest is recommended for any use case other than testing.
    digest = "sha256:deadbeef",
  )


For use case 3.2. If you are using a custom container, and don't
want to generate configs every time. The setup is as follows:

Define a repo (can be the same where you host the sources you want
to build on RBE or a separate one) which will host your published
toolchain configs. We call this the "toolchain-config-repo" in the
below

Define a 'toolchain_config_suite_spec', which specifies a container
(repo + registry) and an output_base, the relative path, within
the toolchain-config-repo where toolchain configs will be published to.
You can only have one 'toolchain_config_suite_spec' per container for which
you will be producing toolchain configs for, but multiple versions of the same
container (i.e., with different sha / tags) can share the same
'toolchain_config_suite_spec'.
Also, the same 'toolchain_config_suite_spec' can also be used to host
multiple toolchain configs that vary in environment variables, and
additional config repos (i.e., repos corresponding to configure like
repository rules) that are needed for different types of builds. For example,
a configuration for msan (which needs specific env variables) and one for
default C++ builds can share an output_base.
Lastly, a 'toolchain_config_suite_spec' will store configs for several
versions of Bazel (any that you specify).

For detailed instructions of how to set up a 'toolchain_config_suite_spec'
please see //rules/rbe_repo/toolchain_config_suite_spec.bzl

Once you have set up the toolchain_config_suite_spec you can add to your
WORKSPACE the following:

  <Add the bazel-toolchains repo http_archive, same as above>

  load("//path/to_your/toolchain_config_suite_spec.bzl", "your_toolchain_config_suite_spec_struct")

  rbe_autoconfig(
    name = "rbe_your_custom_toolchain_config_suite_spec",
    export_configs = True,
    toolchain_config_suite_spec = your_toolchain_config_suite_spec_struct,
  )

You can then run:

RBE_AUTOCONF_ROOT=$(pwd) bazel build @rbe_your_custom_toolchain_config_suite_spec//...

This will create the toolchain configs in the 'output_base' defined in the
'toolchain_config_suite_spec'. It will generate configs for the current version
of Bazel you are running with (overridable via attr).
This will also (abusing Bazel hermeticity principles) modify the versions.bzl
file in the 'output_base'. This is so that subsequent executions of the target
(by you, or by any of your users after you have checked-in these generated files)
will be able to directly use them without having to generate them again.
You should check-in your repo these changes so that the generated configs
are available to all other users of your repo.

For users of your 'toolchain_config_suite_spec' all that they need to do is
add to their WORKSPACE:

  <Add the bazel-toolchains repo http_archive, same as above>

  load("//path/to_your/toolchain_config_suite_spec.bzl", "your_toolchain_config_suite_spec_struct")

  rbe_autoconfig(
    name = "rbe_your_custom_toolchain_config_suite_spec",
    toolchain_config_suite_spec = your_toolchain_config_suite_spec_struct,
  )

And that's it! They should be able to get checked-in configs every time,
as long as, whenever there is a new Bazel needed for RBE builds:
  - You, the owner of the 'toolchain_config_suite_spec' generates and
    publishes the new toolchain configs to your repo. This is needed because
    new Bazel versions can only be guaranteed to work with toolchain
    configs that were generated for the specific version of Bazel used.
  - The users of your 'toolchain_config_suite_spec' update their pin to
    your repo.

If you want to create (more) different sets of toolchain configurations (a toolchain_config_spec)
with a different set of env variables, you can do so by reusing the
'toolchain_config_suite_spec', and providing a distinct 'toolchain_config_spec_name'. Example:

rbe_autoconfig(
    name = "rbe_custom_env2",
    env = {<dict declaring env variables>},
    export_configs = True,
    toolchain_config_spec_name = "<unique name to assign this toolchain_config_spec>",
    toolchain_config_suite_spec = your_toolchain_config_suite_spec_struct,
)

rbe_autoconfig(
    name = "rbe_custom_env2",
    env = {<dict declaring env variables>},
    export_configs = True,
    toolchain_config_spec_name = "<unique name to assign this toolchain_config_spec>",
    toolchain_config_suite_spec = your_toolchain_config_suite_spec_struct,
)

As of Bazel 0.29.0, platforms support exec_properties instead of the deprecated
remote_execution_properties to configure remote execution properties. The new
field is a string->string dictionary rather than a proto serialized as a
string.

rbe_autoconfig now has a field use_legacy_platform_definition, which for
backward compatibility reasons is set by default to True. Setting it to False
causes the underlying platform to be configured using the new exec_properties
field.

Furthermore, rbe_autoconfig itself also has an exec_properties field. Any
values set there are used in configuring the underlying platform. This field
only works if use_legacy_platform_definition is set to False.

Note that the container image cannot be set in rbe_autoconfig via the
exec_properties field.

Here is an example of an rbe_autoconfig that configures its underlying platform
to set the size of the shared memory partition for the docker container to 128
megabytes.

load("@bazel_toolchains//rules/exec_properties:exec_properties.bzl", "create_rbe_exec_properties_dict")

rbe_autoconfig(
    name = "rbe_default",
    use_legacy_platform_definition = False,
    exec_properties = create_rbe_exec_properties_dict(docker_shm_size = "128m"),
)

Note the use of create_rbe_exec_properties_dict. This is a Bazel macro that
makes it convenient to create the dicts used in exec_properties. You should
always prefer to use it over composing the dict manually.

Additionally, there are standard execution property dicts that you may want to
use. These standard dicts should always be preferred if defined. These standard
dicts are defined in a local repo that can be set up via a Bazel macro called
rbe_exec_properties. The following example has rbe_autoconfig create an
underlying platform that allows network access to the remote execution worker.

load("@bazel_toolchains//rules/exec_properties:exec_properties.bzl", "rbe_exec_properties")

rbe_exec_properties(
    name = "exec_properties",
)

load("@exec_properties//:constants.bzl", "NETWORK_ON")

rbe_autoconfig(
    name = "rbe_default",
    use_legacy_platform_definition = False,
    exec_properties = NETWORK_ON,
)

For more information on create_rbe_exec_properties_dict, rbe_exec_properties
and other related Bazel macros, see https://github.com/bazelbuild/bazel-toolchains/tree/master/rules/exec_properties

NOTES:

READ CAREFULLY THROUGH THESE NOTES, NO MATTER YOUR USE CASE:

NOTE 1: SETTING TOOLCHAIN FLAGS

This is not an up to date source for flags, and just provides general guidance
please see //bazelrc/.latest.bazelrc for the most up to date flags.

Once you have added the rbe_autoconfig rule to your WORKSPACE, you will
need to set up toolchain flags that select the appropriate toolchain configs.
The flags below, show an sample of those flags, which was last reviewed
with Bazel 0.25.0 and for a rbe_autoconfig rule with name 'rbe_default'.
If you are using a later version of Bazel or your rbe_autoconfig target
has a different name, please adjust accordingly.

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

NOTE 2: WHEN DOES THIS RULE PULL A CONTAINER

Most users of rbe_autoconfig do not expect their target to pull a container.
If your rbe_autoconfig rule nevertheless pulls a container its because it
could not find checked-in configs that match:
1- The Bazel version you are currently using
2- The container you selected (if you are not setting base_container_digest)
3- The environment or config repos you requested

The simplest fix for 1 is to update your pin to the bazel-toolchains repo (and
to the source of your custom 'toolchain_config_suite_spec'). If that does not
fix the issue, you can try to use an older toolchain cofig by passing
an older version in the bazel_version 'attr' (which may or may not work with
the current version you are running). You should also contact the owners of
bazel-toolchains (or the custom 'toolchain_config_suite_spec' repo) to have them
publish configs for any new version if they have not done so.

The simplest fix for 2, is to rebuild your custom container using as base
the latest version of the base_container_digest. If that does not work, contact
the owners of the bazel-toolchains repo (i.e., create an issue in this repo)
or the owners of custom 'toolchain_config_suite_spec' repo if you are using one.

The only possible fix for 3, if you want this custom config spec to be supported
with checked-in configs, is to contact the owners of the bazel-toolchains repo
(or the custom 'toolchain_config_suite_spec' repo), to ask them to add this spec
to their WORKSPACE and generate configs for it.

NOTE 3: USE OF PROJECT ROOT

When this rule needs to export toolchain configs, or when it needs
to generate configs for custom config repos (i.e., corresponding to
configure like repo rules needed in your RBE build), This rule depends
on the value of the environment variable "RBEAUTOCONF_ROOT".

This env var should be set to point to the absolute path root of your project.
Use the full absolute path to the project root (i.e., no '~', '../', or
other special chars).

NOTE 4: PREREQUISITES FOR RUNNING THIS RULE

If this rule needs to generate configs, it expects the following
utilities to be installed and available on the PATH:
  - docker
  - tar
  - bash utilities (e.g., cp, mv, rm, etc)
  - docker authentication to pull the desired container should be set up
    (rbe-ubuntu16-04 does not require any auth setup currently).

NOTE 5: HERMETICITY AND THIS RULE

Note this is a very not hermetic repository rule that can actually change the
contents of your project sources. While this is generally not recommended by
Bazel, its the only reasonable way to get a rule that can produce valid
toolchains / platforms that need to be made available to Bazel before execution
of any build actions, AND at the same time, make them available to other
users so they do not need to be regenerated again. This can be done, safely,
to a certain extent, because these containers are pulled and dealt with by
SHA, all the outputs produced should be completely independent of where they
were built and can be leveraged by all users of a container.

NOTE 6: KNOWN LIMITATIONS

  - This rule can only run on Linux or Windows if it needs to generate configs.
  - This rule uses Bazelisk to run Bazel inside the given container.
    The container, thus, must be able to execute the Bazelisk binary
    (i.e., Linux or Windows based container must be capable of running
    the respective linux-amd or windows-amd releases from
    https://github.com/bazelbuild/bazelisk/releases)
  - If using export_configs, and you have multiple rbe_autoconfig targets
    pointing to the same toolchain_config_suite_spec, these rules should not
    be executed together in the same bazel command, as they all depend on
    reading/writing to the same versions.bzl file.
  - This rule cannot generate configs if: 1) it needs to pull additional
    config repos and 2) the project's WORKSPACE contains local_repository
    rules pointing to directories above the project root.
"""

load(
    "//configs/dependency-tracking:ubuntu1604.bzl",
    BAZEL_LATEST = "bazel",
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
    "create_configs_tar",
    "create_versions_file",
    "expand_outputs",
)
load(
    "//rules/rbe_repo:toolchain_config_suite_spec.bzl",
    "config_to_string_lists",
    "default_toolchain_config_suite_spec",
    "validate_toolchain_config_suite_spec",
)
load(
    "//rules/rbe_repo:util.bzl",
    "AUTOCONF_ROOT",
    "DOCKER_PATH",
    "copy_to_test_dir",
    "os_family",
    "print_exec_results",
    "resolve_image_name",
    "resolve_project_root",
    "resolve_rbe_original_image_name",
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

_DEFAULT_TOOLCHAIN_CONFIG_SPEC_NAME = "default_toolchain_config_spec_name"

_EXEC_COMPAT_WITH = {
    "Linux": [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//tools/cpp:clang",
    ],
    "Windows": [
        "@bazel_tools//platforms:windows",
        "@bazel_tools//platforms:x86_64",
    ],
}
_TARGET_COMPAT_WITH = {
    "Linux": [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
    ],
    "Windows": [
        "@bazel_tools//platforms:windows",
        "@bazel_tools//platforms:x86_64",
    ],
}

def _rbe_autoconfig_impl(ctx):
    """Core implementation of _rbe_autoconfig repository rule."""

    bazel_version_debug = "Bazel %s" % ctx.attr.bazel_version
    if ctx.attr.bazel_rc_version:
        bazel_version_debug += " rc%s" % ctx.attr.bazel_rc_version
    print("%s is used in %s." % (bazel_version_debug, ctx.attr.name))

    if ctx.attr.use_checked_in_confs == CHECKED_IN_CONFS_FORCE and not ctx.attr.config_version:
        fail(("Target '{name}' failed: use_checked_in_confs was set to '{force}' " +
              "but no checked-in configs were found. " +
              "Please check your pin to '@{toolchain_config_suite_spec_repo_name}' is up " +
              "to date, and that you are using a release version of " +
              "Bazel. You can also explicitly set the version of Bazel to " +
              "an older version in the '{name}' rbe_autoconfig target " +
              "which may or may not work with the version you are currently " +
              "running with.").format(
            name = ctx.attr.name,
            force = CHECKED_IN_CONFS_FORCE,
            toolchain_config_suite_spec_repo_name = ctx.attr.toolchain_config_suite_spec["repo_name"],
        ))

    name = ctx.attr.name
    image_name = resolve_image_name(ctx)
    docker_tool_path = None

    # Resolve default constraints if none set
    target_compatible_with = ctx.attr.target_compatible_with
    if not target_compatible_with:
        target_compatible_with = _TARGET_COMPAT_WITH[os_family(ctx)]

    exec_compatible_with = ctx.attr.exec_compatible_with
    if not exec_compatible_with:
        exec_compatible_with = _EXEC_COMPAT_WITH[os_family(ctx)]

    # Resolve the paths to copy srcs to the container and to
    # export configs.
    mount_project_root, export_project_root, use_default_project = resolve_project_root(ctx)

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

    # Get the value of JAVA_HOME to set in the produced
    # java_runtime
    java_home = None
    if ctx.attr.create_java_configs:
        java_home = get_java_home(ctx, docker_tool_path, image_name)
        if java_home:
            create_java_runtime(ctx, java_home)

    toolchain_config_spec_name = ctx.attr.toolchain_config_spec_name
    if ctx.attr.config_version:
        # If we found a config we pass it to the toolchain_config_spec_name so when
        # we produce platform BUILD file we can use it.
        toolchain_config_spec_name = ctx.attr.config_version
    else:
        # If no config_version was found, generate configs

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
                project_root = mount_project_root,
                use_default_project = use_default_project,
            )

        if ctx.attr.export_configs:
            ctx.report_progress("expanding outputs")

            # If the user requested exporting configs and did not set a toolchain_config_spec_name lets pick the default
            if not toolchain_config_spec_name:
                toolchain_config_spec_name = ctx.attr.toolchain_config_suite_spec["default_toolchain_config_spec"]

            # Create a default BUILD file with the platform + toolchain targets that
            # will work with RBE with the produced toolchain (to be exported to
            # output_dir)
            ctx.report_progress("creating export platform")
            create_export_platform(
                ctx,
                exec_properties = ctx.attr.exec_properties,
                exec_compatible_with = exec_compatible_with,
                target_compatible_with = target_compatible_with,
                image_name = resolve_rbe_original_image_name(ctx, image_name),
                name = name,
                toolchain_config_spec_name = toolchain_config_spec_name,
                use_legacy_platform_definition = ctx.attr.use_legacy_platform_definition,
            )

            # Create the versions.bzl file
            if ctx.attr.create_versions:
                create_versions_file(
                    ctx,
                    digest = digest,
                    toolchain_config_spec_name = toolchain_config_spec_name,
                    java_home = java_home,
                    project_root = export_project_root,
                )

            # Expand outputs to project dir
            expand_outputs(
                ctx,
                bazel_version = ctx.attr.bazel_version,
                project_root = export_project_root,
                toolchain_config_spec_name = toolchain_config_spec_name,
            )
        else:
            ctx.report_progress("creating external repo platform")
            create_external_repo_platform(
                ctx,
                exec_properties = ctx.attr.exec_properties,
                exec_compatible_with = exec_compatible_with,
                target_compatible_with = target_compatible_with,
                image_name = resolve_rbe_original_image_name(ctx, image_name),
                name = name,
                use_legacy_platform_definition = ctx.attr.use_legacy_platform_definition,
            )
            create_configs_tar(ctx)

    # If we found checked in confs or if outputs were moved
    # to output_base create the alisases.
    if ctx.attr.config_version or ctx.attr.export_configs:
        create_config_aliases(ctx, toolchain_config_spec_name)
        create_alias_platform(
            ctx,
            exec_properties = ctx.attr.exec_properties,
            exec_compatible_with = exec_compatible_with,
            target_compatible_with = target_compatible_with,
            image_name = resolve_rbe_original_image_name(ctx, image_name),
            name = name,
            toolchain_config_spec_name = toolchain_config_spec_name,
            use_legacy_platform_definition = ctx.attr.use_legacy_platform_definition,
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
                   "extends from the one defined in the 'toolchain_config_suite_spec' " +
                   "(defaults to rbe-ubuntu16-04 image), you can " +
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
        "bazel_to_config_spec_names_map": attr.string_list_dict(
            doc = ("Set by rbe_autoconfig macro. A dict with keys corresponding to bazel versions, " +
                   "values corresponding to lists of configs. Must point to the " +
                   "bazel_to_config_versions def in the versions.bzl file " +
                   "located in the 'output_base' of the 'toolchain_config_suite_spec'."),
        ),
        "bazel_version": attr.string(
            default = "local",
            doc = ("The version of Bazel to use to generate toolchain configs." +
                   "Use only (major, minor, patch), e.g., '0.20.0'."),
            mandatory = True,
        ),
        "toolchain_config_spec_name": attr.string(
            doc = ("The name of the toolchain config spec to be generated."),
        ),
        "configs_obj_config_repos": attr.string_list(
            doc = ("Set by rbe_autoconfig macro. Set to list 'config_repos' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/toolchain_config_suite_spec.bzl."),
        ),
        "configs_obj_create_cc_configs": attr.string_list(
            doc = ("Set by rbe_autoconfig macro. Set to list 'cc_configs' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/toolchain_config_suite_spec.bzl."),
        ),
        "configs_obj_create_java_configs": attr.string_list(
            doc = ("Set by rbe_autoconfig macro. Set to list 'java_configs' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/toolchain_config_suite_spec.bzl."),
        ),
        "configs_obj_env_keys": attr.string_list(
            doc = ("Set by rbe_autoconfig macro. Set to list 'env_keys' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/toolchain_config_suite_spec.bzl."),
        ),
        "configs_obj_env_values": attr.string_list(
            doc = ("Set by rbe_autoconfig macro. Set to list 'env_values' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/toolchain_config_suite_spec.bzl."),
        ),
        "configs_obj_java_home": attr.string_list(
            doc = ("Set by rbe_autoconfig macro. Set to list 'java_home' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/toolchain_config_suite_spec.bzl."),
        ),
        "configs_obj_names": attr.string_list(
            doc = ("Set by rbe_autoconfig macro. Set to list 'names' generated by config_to_string_lists def in " +
                   "//rules/rbe_repo/toolchain_config_suite_spec.bzl."),
        ),
        "config_repos": attr.string_list(
            doc = ("Set by rbe_autoconfig macro. list of additional external repos corresponding to " +
                   "configure like repo rules that need to be produced in addition to " +
                   "local_config_cc."),
        ),
        "config_version": attr.string(
            doc = ("The config version found for the given container and " +
                   "Bazel version. " +
                   "Used internally when use_checked_in_confs is true."),
        ),
        "container_to_config_spec_names_map": attr.string_list_dict(
            doc = ("Set by rbe_autoconfig macro. A dict with keys corresponding to containers and " +
                   "values corresponding to lists of configs. Must point to the " +
                   "container_to_config_version def in the versions.bzl file " +
                   "located in the 'output_base' of the 'toolchain_config_suite_spec'."),
        ),
        "create_cc_configs": attr.bool(
            doc = (
                "Specifies whether to generate C/C++ configs. " +
                "Defauls to True."
            ),
            mandatory = True,
        ),
        "create_java_configs": attr.bool(
            doc = (
                "Optional. Specifies whether to generate java configs. " +
                "Defauls to True."
            ),
            mandatory = True,
        ),
        "create_testdata": attr.bool(
            doc = (
                "Specifies whether to generate additional " +
                "testing only outputs. " +
                "Defauls to False."
            ),
            mandatory = True,
        ),
        # TODO(ngiraldo): remove once migration to use generated file completes
        "create_versions": attr.bool(
            doc = (
                "Specifies whether to generate versions.bzl " +
                "file in output_base of the toolchain_config_suite_spec. " +
                "This option is temporary while migration to use. " +
                "generated file by this rule is taking place. " +
                "Defauls to True."
            ),
            mandatory = True,
        ),
        "detect_java_home": attr.bool(
            doc = (
                "Specifies whether to find the JAVA_HOME as set in the" +
                "container. " +
                "Defauls to False."
            ),
            mandatory = True,
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
            doc = ("Optional. The list of constraints that will be added to the " +
                   "toolchain in its exec_compatible_with attribute (and to " +
                   "the platform in its constraint_values attr). For " +
                   "example, [\"@bazel_tools//platforms:linux\"]."),
        ),
        "exec_properties": attr.string_dict(
            doc = (
                "Optional. The execution properties to be used when creating the " +
                "underlying platform. When providing this attribute, " +
                "use_legacy_platform_definition must be set to False. Note that " +
                "the container image property must not be specified via this " +
                "attribute."
            ),
        ),
        "export_configs": attr.bool(
            doc = (
                "Specifies whether to copy generated configs to the 'output_base' " +
                "of the 'toolchain_config_suite_spec' (if configs are generated) " +
                "If set to False, a configs.tar file will also be produced in the " +
                ("external repo. This tar file can be then published to a URL and " +
                 " e.g., be  used via an 'http_archive' rule from an arbitrary repo." +
                 "Default is False.")
            ),
            mandatory = True,
        ),
        "java_home": attr.string(
            doc = ("Optional. The location of java_home in the container. For " +
                   "example , '/usr/lib/jvm/java-8-openjdk-amd64'. Only " +
                   "relevant if 'create_java_configs' is true. If 'create_java_configs' is " +
                   "true, the execution of the rule generates configs, and this attribute " +
                   "is not set, the rule will attempt to read the " +
                   "JAVA_HOME env var from the container. If that is not set, the rule " +
                   "will fail."),
        ),
        "registry": attr.string(
            doc = ("Optional. The registry to pull the container from. For example, " +
                   "marketplace.gcr.io. The default is the value for the selected " +
                   "toolchain_config_suite_spec (rbe-ubuntu16-04 image for " +
                   "default_toolchain_config_suite_spec, if no toolchain_config_suite_spec was selected)."),
        ),
        "repository": attr.string(
            doc = ("Optional. The repository to pull the container from. For example, " +
                   "google/ubuntu. The default is the " +
                   "value for the selected toolchain_config_suite_spec (rbe-ubuntu16-04 image for " +
                   "default_toolchain_config_suite_spec, if no toolchain_config_suite_spec was selected)."),
        ),
        "toolchain_config_suite_spec": attr.string_dict(
            doc = ("Set by rbe_autoconfig macro. Dict containing values to identify a " +
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
            doc = ("The list of constraints that will be added to the " +
                   "toolchain in its target_compatible_with attribute. For " +
                   "example, [\"@bazel_tools//platforms:linux\"]."),
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
        "use_legacy_platform_definition": attr.bool(
            doc = (
                "Specifies whether the underlying platform uses the " +
                "remote_execution_properties property (if use_legacy_platform_definition " +
                "is True) or the exec_properties property. The reason why this " +
                "is important is because a platform that inherits from this " +
                "platform and wishes to add execution properties must use the " +
                "same field remote_execution_properties/exec_properties that " +
                "the parent platform uses. This attribute must be set to False if the " +
                "exec_properties attribute is set."
            ),
            mandatory = True,
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
        toolchain_config_spec_name = None,
        config_repos = None,
        create_cc_configs = True,
        create_java_configs = True,
        create_testdata = False,
        create_versions = True,
        detect_java_home = False,
        digest = None,
        env = None,
        exec_compatible_with = None,
        exec_properties = None,
        export_configs = False,
        java_home = None,
        tag = None,
        toolchain_config_suite_spec = default_toolchain_config_suite_spec(),
        registry = None,
        repository = None,
        target_compatible_with = None,
        use_checked_in_confs = CHECKED_IN_CONFS_TRY,
        use_legacy_platform_definition = True):
    """ Creates a repository with toolchain configs generated for a container image.

    This macro wraps (and simplifies) invocation of _rbe_autoconfig rule.
    Use this macro in your WORKSPACE.

    Args:
      name: Name of the rbe_autoconfig repository target.
      base_container_digest: Optional. If the container to use for the RBE build
          extends from the container defined in the toolchain_config_suite_spec
          (by default, the rbe-ubuntu16-04 image), you can pass the digest
          (sha256 sum) of the base container using this attr.
          The rule will try to use of checked-in configs, if possible.
      bazel_version: The version of Bazel to use to generate toolchain configs.
          `Use only (major, minor, patch), e.g., '0.20.0'. Default is "local"
          which means the same version of Bazel that is currently running will
          be used. If local is a non release version, rbe_autoconfig will fallback
          to using the latest release version (see _BAZEL_VERSION_FALLBACK).
          Note, if configs are not found for a patch version, rule will attempt
          to find ones for the corresponding x.x.0 version. So if you are using
          Bazel 0.25.2, and configs are not found for that version, but are
          available for 0.25.0, those will be used instead. Note: this is only
          the case if use_checked_in_confs != "False" (string 'False').
      bazel_rc_version: The rc (for the given version of Bazel) to use.
          Must be published in https://releases.bazel.build. E.g. 2.
      toolchain_config_spec_name: Optional. String. Override default config
          defined in toolchain_config_suite_spec.
          If export_configs is True, this value is used to set the name of the
          toolchain config spec to be generated.
      config_repos: Optional. List of additional external repos corresponding to
          configure like repo rules that need to be produced in addition to
          local_config_cc.
      create_cc_configs: Optional. Specifies whether to generate C/C++ configs.
          Defauls to True.
      create_java_configs: Optional. Specifies whether to generate java configs.
          Defauls to True.
      create_testdata: Optional. Specifies whether to generate additional testing
          only outputs. Defauls to False.
      create_versions: Specifies whether to generate versions.bzl
          file in 'output_base' of the 'toolchain_config_suite_spec'.
          This option is temporary while migration to use.
          generated file by this rule is taking place.
          Defauls to True.
      digest: Optional. The digest of the image to pull.
          Should not be set if 'tag' is used.
          Must be set together with 'registry' and 'repository'.
      detect_java_home: Optional. Default False. Should only be set
          to True if 'create_java_configs' is also True. If set to True the rule
          will attempt to read the JAVA_HOME env var from the container.
          Note if java_home is not set and this is set to False, the rule will
          attempt to find a value of java_home in a compatible
          'toolchain_config_spec', fallback to using the 'default_java_home' in
          the 'toolchain_config_suite_spec', fallback to turning on 'detect_java_home,
          (unless use_checked_in_confs = Force was set), or otherwise fail with an
          informative error.
      env: dict. Optional. Additional environment variables that will be set when
          running the Bazel command to generate the toolchain configs.
          Set to values for marketplace.gcr.io/google/rbe-ubuntu16-04 container.
          Note: Do not pass a custom JAVA_HOME via env, use java_home attr instead.
      exec_compatible_with: Optional. List of constraints to add to the produced
          toolchain/platform targets (e.g., ["@bazel_tools//platforms:linux"] in the
          exec_compatible_with/constraint_values attrs, respectively.
      exec_properties: Optional. A string->string dict containing execution
          properties to be used when creating the underlying platform. When
          providing this attribute use_legacy_platform_definition must be set
          to False. Note that the container image property must not be specified
          via this attribute.
      export_configs: Optional, default False. Whether to copy generated configs
          (if they are generated) to the 'output_base' defined in
          'toolchain_config_suite_spec'. If set to False, a configs.tar file
          will also be produced in the external repo. This tar file can be then
          published to a URL and e.g., be used via an 'http_archive' rule
          from an arbitrary repo.
      java_home: Optional. The location of java_home in the container. For
          example , '/usr/lib/jvm/java-8-openjdk-amd64'. Should only be set
          if 'create_java_configs' is True. Cannot be set if detect_java_home
          is set to True.
          Note if detect_java_home is set to False and this is not set, the
          rule will attempt to find a value of java_home in a compatible
          'toolchain_config_spec', fallback to using the 'default_java_home' in
          the 'toolchain_config_suite_spec', fallback to turning on 'detect_java_home'
          (unless use_checked_in_confs = Force was set), or otherwise fail with an
          informative error.
      tag: Optional. The tag of the container to use.
          Should not be set if 'digest' is used.
          Must be set together with 'registry' and 'repository'.
          Note if you use any tag other than 'latest' (w/o specifiyng 'base_container_digest')
          configs will need to be generaed, and a container will need to be pulled.
          Note using 'latest' will default to the 'latest_container'
          defined in the 'toolchain_config_suite_spec'
      toolchain_config_suite_spec: Optional. Defaults to using @bazel_toolchains as
          source for toolchain_config_suite_spec.
          Should only be set differently if you are using a diferent repo
          as source for your toolchain configs.
          For details of the expected structure of toolchain_config_suite_spec dict please see
          //rules/rbe_repo:toolchain_config_suite_spec.bzl
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
      use_legacy_platform_definition: Defaults to True (for now).
          Specifies whether the underlying platform uses the
          remote_execution_properties property (if use_legacy_platform_definition
          is True) or the exec_properties property. The reason why this
          is important is because a platform that inherits from this
          platform and wishes to add execution properties must use the
          same field remote_execution_properties/exec_properties that
          the parent platform uses. This attribute must be set to False if the
          exec_properties attribute is set.
    """
    if not use_checked_in_confs in CHECKED_IN_CONFS_VALUES:
        fail("use_checked_in_confs must be one of %s." % CHECKED_IN_CONFS_VALUES)

    if bazel_rc_version and not bazel_version:
        fail("bazel_rc_version can only be used with bazel_version.")

    if not create_java_configs and (java_home or detect_java_home):
        fail("java_home / detect_java_home should not be set when " +
             "create_java_configs is False.")
    if java_home and detect_java_home:
        fail("java_home should not be set when detect_java_home is True.")

    validate_toolchain_config_suite_spec(name, toolchain_config_suite_spec)

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

    if use_legacy_platform_definition == True and exec_properties:
        fail("exec_properties must not be set when " +
             "use_legacy_platform_definition is True.")

    if exec_properties and "container-image" in exec_properties:
        fail("exec_properties must not contain a container image")

    # Set to defaults only if all are unset.
    if not repository and not registry and not tag and not digest:
        repository = toolchain_config_suite_spec["container_repo"]
        registry = toolchain_config_suite_spec["container_registry"]

    toolchain_config_spec, selected_digest = validateUseOfCheckedInConfigs(
        name = name,
        base_container_digest = base_container_digest,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        config_repos = config_repos,
        create_cc_configs = create_cc_configs,
        detect_java_home = detect_java_home,
        digest = digest,
        env = env,
        java_home = java_home,
        toolchain_config_suite_spec = toolchain_config_suite_spec,
        registry = registry,
        repository = repository,
        requested_toolchain_config_spec_name = toolchain_config_spec_name,
        tag = tag,
        use_checked_in_confs = use_checked_in_confs,
    )

    # If create_java_configs was requested but no java_home or detect_java_home was
    # set, we try to resolve a java_home
    if create_java_configs and not java_home and not detect_java_home:
        # If a spec was found and that has a java_home, use it
        if toolchain_config_spec and toolchain_config_spec.create_java_configs:
            java_home = toolchain_config_spec.java_home

        elif toolchain_config_suite_spec.get("default_java_home"):
            # Fallback to try to using the default_java_home set in the
            # toolchain_config_suite_spec
            java_home = toolchain_config_suite_spec.get("default_java_home")

        elif use_checked_in_confs != CHECKED_IN_CONFS_FORCE:
            # Fallback to detecting the java_home if CHECKED_IN_CONFS_FORCE
            # was not passed
            detect_java_home = True

        elif toolchain_config_spec and use_checked_in_confs == CHECKED_IN_CONFS_FORCE:
            # If we get here, the toolchain_config_spec we found does not
            # provide a java_home that we can use, and the toolchain_config_suite_spec
            # does not have a default one either, so just fail early.
            fail(("Target '{name}' failed: use_checked_in_confs was set to '{force}' " +
                  "but no checked-in configs were found which provide a value for java_home. " +
                  "This may be solved by defining a 'default_java_home' in the " +
                  "toolchain_config_spec or by explicitly setting 'java_home' in '{name}'").format(
                name = name,
                force = CHECKED_IN_CONFS_FORCE,
            ))

    # If the user selected no digest explicitly, and one was returned
    # by validateUseOfCheckedInConfigs, use that one.
    if not digest and selected_digest:
        digest = selected_digest
    default_toolchain_config_spec_set = toolchain_config_suite_spec.get("toolchain_config_suite_autogen_spec").default_toolchain_config_spec != ""

    # If using the registry and repo defined in the toolchain_config_suite_spec struct then
    # set the env if its not set (if defined in toolchain_config_suite_spec).
    # Also try to set the digest (preferably to avoid pulling container),
    # default to setting the tag to 'latest'
    if ((registry and registry == toolchain_config_suite_spec["container_registry"]) and
        (repository and repository == toolchain_config_suite_spec["container_repo"])):
        if not env and default_toolchain_config_spec_set:
            env = toolchain_config_suite_spec.get("toolchain_config_suite_autogen_spec").default_toolchain_config_spec.env
        if tag == "latest" and toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container != "":
            tag = None
            digest = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container
        if not digest and not tag and toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container != "":
            digest = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container
        if not digest and not tag:
            tag = "latest"
    default_toolchain_config_spec = _DEFAULT_TOOLCHAIN_CONFIG_SPEC_NAME if not default_toolchain_config_spec_set else toolchain_config_suite_spec.get("toolchain_config_suite_autogen_spec").default_toolchain_config_spec.name

    # Replace the default_toolchain_config_spec struct for its name, as the rule expects a string dict.
    # also, dont include the toolchain_config_suite_autogen_spec attr as its a struct (which we flatten below)
    toolchain_config_suite_spec_stripped = {
        "default_toolchain_config_spec": default_toolchain_config_spec,
        "repo_name": toolchain_config_suite_spec["repo_name"],
        "output_base": toolchain_config_suite_spec["output_base"],
        "container_repo": toolchain_config_suite_spec["container_repo"],
        "container_registry": toolchain_config_suite_spec["container_registry"],
        "latest_container": toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container,
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

    bazel_to_config_spec_names_map = None
    container_to_config_spec_names_map = None
    if export_configs:
        # Flatten toolchain_config_specs structs to pass configs to rule
        config_objs = config_to_string_lists(toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].toolchain_config_specs)
        bazel_to_config_spec_names_map = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].bazel_to_config_spec_names_map
        container_to_config_spec_names_map = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map

    _rbe_autoconfig(
        name = name,
        base_container_digest = base_container_digest,
        bazel_version = bazel_version,
        bazel_rc_version = bazel_rc_version,
        bazel_to_config_spec_names_map = bazel_to_config_spec_names_map,
        toolchain_config_spec_name = toolchain_config_spec_name,
        configs_obj_names = config_objs.names,
        configs_obj_java_home = config_objs.java_home if create_java_configs else None,
        configs_obj_create_java_configs = config_objs.create_java_configs,
        configs_obj_create_cc_configs = config_objs.create_cc_configs,
        configs_obj_config_repos = config_objs.config_repos,
        configs_obj_env_keys = config_objs.env_keys,
        configs_obj_env_values = config_objs.env_values,
        config_repos = config_repos,
        config_version = None if toolchain_config_spec == None else toolchain_config_spec.name,
        container_to_config_spec_names_map = container_to_config_spec_names_map,
        create_cc_configs = create_cc_configs,
        create_java_configs = create_java_configs,
        create_testdata = create_testdata,
        create_versions = create_versions,
        detect_java_home = detect_java_home,
        digest = digest,
        env = env,
        exec_compatible_with = exec_compatible_with,
        exec_properties = exec_properties,
        export_configs = export_configs,
        java_home = java_home,
        toolchain_config_suite_spec = toolchain_config_suite_spec_stripped,
        registry = registry,
        repository = repository,
        tag = tag,
        target_compatible_with = target_compatible_with,
        use_checked_in_confs = use_checked_in_confs,
        use_legacy_platform_definition = use_legacy_platform_definition,
    )
