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
"""Utils for rbe_autoconfig."""

load(
    "//rules/rbe_repo:toolchain_config_suite_spec.bzl",
    "default_toolchain_config_suite_spec",
)

_VERBOSE = False

DOCKER_PATH = "DOCKER_PATH"
CC_CONFIG_DIR = "cc"
JAVA_CONFIG_DIR = "java"
PLATFORM_DIR = "config"
AUTOCONF_ROOT = "RBE_AUTOCONF_ROOT"

def resolve_image_name(ctx):
    """
    Gets the image name.

    If the image corresponds to the
    one in the default_toolchain_config_suite_spec, replaces
    the login required endpoint (marketplace.gcr.io)
    with the public access endpoint (l.gcr.io)

    Args:
      ctx: the Bazel context object.

    Returns:
        the name of the image
    """

    image_name = None
    if ctx.attr.digest:
        image_name = ctx.attr.registry + "/" + ctx.attr.repository + "@" + ctx.attr.digest
    else:
        image_name = ctx.attr.registry + "/" + ctx.attr.repository + ":" + ctx.attr.tag

    if (ctx.attr.repository == default_toolchain_config_suite_spec()["container_repo"] and
        ctx.attr.registry == default_toolchain_config_suite_spec()["container_registry"]):
        # Use l.gcr.io registry to pull marketplace.gcr.io images to avoid auth
        # issues for users who do not do gcloud login.
        image_name = image_name.replace("marketplace.gcr.io", "l.gcr.io")

    return image_name

def resolve_rbe_original_image_name(ctx, image_name):
    """
    Resolves the original image name

    If the image corresponds to the one in the
    default_toolchain_config_suite_spec, converts its name from using public
    access endpoint (marketplace.gcr.io) to its login required endpoint
    (l.gcr.io)

    Args:
      ctx: the Bazel context object.
      image_name: the name of the image.

    Returns:
        the modified name of the image
    """
    if (ctx.attr.repository == default_toolchain_config_suite_spec()["container_repo"] and
        ctx.attr.registry == default_toolchain_config_suite_spec()["container_registry"]):
        return image_name.replace("l.gcr.io", "marketplace.gcr.io")
    return image_name

def resolve_project_root(ctx):
    """Returns the project_root .

    Returns the project_root that will be used to copy sources
    to the container (if needed) and whether or not the default cc project
    was selected.

    Args:
      ctx: the Bazel context object.

    Returns:
        mount_project_root - path to mount/copy to the container to execute command to generate external repos
        export_project_root - path to export produced configs to
    """

    if ctx.attr.config_version:
        return None, None, None

    export_project_root = None
    mount_project_root = None
    use_default_project = False

    # If not using checked-in configs and either export configs was selected or
    # config_repos were requested we need to resolve the path to the project root
    # using the env variable.
    if ctx.attr.export_configs or ctx.attr.config_repos:
        # We need AUTOCONF_ROOT to be set to either export or copy to the container
        project_root = ctx.os.environ.get(AUTOCONF_ROOT, None)

        # TODO (nlopezgi): validate _AUTOCONF_ROOT points to a valid Bazel project
        if not project_root:
            fail(("%s env variable must be set for rbe_autoconfig " +
                  "to function properly when export_configs is True " +
                  "or config_repos are set") % AUTOCONF_ROOT)
        if ctx.attr.export_configs:
            export_project_root = project_root
        if ctx.attr.config_repos:
            mount_project_root = project_root
    if not ctx.attr.config_repos:
        # If no config repos, we can use the default sample project
        # TODO(nlopezgi): consider using native.existing_rules() to validate
        # bazel_toolchains repo exists.
        # Try to use the default project
        # This is Bazel black magic, we're traversing the directories in the output_base,
        # assuming that the bazel_toolchains external repo will exist in the
        # expected path.
        mount_project_root = ctx.path(".").dirname.get_child("bazel_toolchains").get_child("rules").get_child("cc-sample-project")
        if not mount_project_root.exists:
            fail(("Could not find default autoconf project in %s, please make sure " +
                  "the bazel-toolchains repo is imported in your workspace with name " +
                  "'bazel_toolchains' and imported before the rbe_autoconfig target " +
                  "declaration ") % str(project_root))
        mount_project_root = str(mount_project_root)
        use_default_project = True

    return mount_project_root, export_project_root, use_default_project

def validate_host(ctx):
    """Perform validations of host environment to be able to run the rule.

    Args:
      ctx: the Bazel context object.

    Returns:
        Returns the path to the docker tool binary.
    """
    if ctx.os.name.lower() != "linux":
        fail("Not running on linux host, cannot run rbe_autoconfig.")
    docker_tool_path = ctx.os.environ.get(DOCKER_PATH, None)
    if not docker_tool_path:
        docker_tool_path = ctx.which("docker")
    if not docker_tool_path:
        fail("Cannot run rbe_autoconfig as 'docker' was not found on the " +
             "path and environment variable DOCKER_PATH was not set. " +
             "rbe_autoconfig attempts to pull a docker container if a " +
             "toolchain config was not found for the version of Bazel " +
             "(selected via attr or implicitly identified). If you do " +
             "not want rbe_autoconfig to ever attempt to pull a docker " +
             "container, please use attr 'use_checked_in_confs = \"Force\"'.")
    result = ctx.execute([docker_tool_path, "ps"])
    if result.return_code != 0:
        fail("Cannot run rbe_autoconfig as running '%s ps' returned a " +
             "non 0 exit code, please check you have permissions to " +
             "run docker. Error message: %s" % docker_tool_path, result.stderr)
    if not ctx.which("tar"):
        fail("Cannot run rbe_autoconfig as 'tar' was not found on the path.")
    print("Found docker tool in %s" % docker_tool_path)
    return str(docker_tool_path)

def print_exec_results(prefix, exec_result, fail_on_error = False, args = None):
    """Convenience method to print results of execute. 

    Convenience method to print results of execute when Verbose logging
    is enabled.
    Also provides functionality to fail on errors if needed.
    Verbose logging is enabled via a global var in this bzl file

    Args:
      prefix: A prefix to add to logs.
      exec_result: The return value of ctx.execute(...).
      fail_on_error: Default False. Whether to fail if exec_result contains an error
      args: args passed to ctx.execute(...).

    """
    if _VERBOSE and exec_result.return_code != 0:
        print(prefix + "::error::" + exec_result.stderr)
    elif _VERBOSE:
        print(prefix + "::success::" + exec_result.stdout)
    if fail_on_error and exec_result.return_code != 0:
        if _VERBOSE and args:
            print("failed to run execute with the following args:" + str(args))
        fail("Failed to run:" + prefix + ":" + exec_result.stderr)

def copy_to_test_dir(ctx):
    """Copies  contents of  external repo test directory.

     Copies all contents of the external repo to a test directory,
     modifies name of all BUILD files (to enable file_test to operate on them), and
     creates a root BUILD file in test directory with a filegroup that contains
     all files.

    Args:
      ctx: the Bazel context object.
    """

    # Copy all files to the test directory
    args = ["bash", "-c", "mkdir ./.test && cp -r ./* ./.test && mv ./.test ./test"]
    result = ctx.execute(args)
    print_exec_results("copy test output files", result, True, args)

    # Rename BUILD files
    ctx.file("rename_build_files.sh", "find ./test -name \"BUILD\" -exec sh -c 'mv \"$1\" \"$(dirname $1)/test.BUILD\"' _ {} \\;", True)
    result = ctx.execute(["./rename_build_files.sh"])
    print_exec_results("Rename BUILD files in test output", result, True, args)

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
    ctx.file("AUTOCONF_ROOT", ctx.os.environ.get(AUTOCONF_ROOT, None), False)
    ctx.file("BUILD", """package(default_visibility = ["//visibility:public"])
exports_files(["AUTOCONF_ROOT"])
""", False)

# Rule that exposes the location of AUTOCONF_ROOT for test
# rules to consume.
rbe_autoconfig_root = repository_rule(
    environ = [
        AUTOCONF_ROOT,
    ],
    implementation = rbe_autoconfig_root_impl,
    local = True,
)
