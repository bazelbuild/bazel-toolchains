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
    "//configs/ubuntu16_04_clang:versions.bzl",
    RBE_UBUNTU16_04_DEFAULT_CONFIG = "DEFAULT_CONFIG",
    RBE_UBUNTU16_04_LATEST = "LATEST",
)

_VERBOSE = False

DOCKER_PATH = "DOCKER_PATH"
CC_CONFIG_DIR = "cc"
JAVA_CONFIG_DIR = "java"
PLATFORM_DIR = "config"
AUTOCONF_ROOT = "RBE_AUTOCONF_ROOT"

def rbe_default_repo():
    return {
        "repo_name": "bazel_toolchains",
        "output_base": "configs/ubuntu16_04_clang",
        "container_repo": "google/rbe-ubuntu16-04",
        "container_registry": "marketplace.gcr.io",
        "latest_container": RBE_UBUNTU16_04_LATEST,
        "default_config": RBE_UBUNTU16_04_DEFAULT_CONFIG,
    }

def resolve_project_root(ctx):
    """Returns the project_root .

    Returns the project_root that will be used to copy sources
    to the container (if needed) and whether or not the default cc project
    was selected.

    Args:
      ctx: the Bazel context object.

    Returns:
        Returns the project_root.
    """

    # If not using checked-in configs and either export configs was selected or
    # config_repos were requested we need to resolve the project_root
    # using the env variable.
    project_root = None
    use_default_project = None
    if not ctx.attr.config_version and (ctx.attr.export_configs or ctx.attr.config_repos):
        project_root = ctx.os.environ.get(AUTOCONF_ROOT, None)
        print("RBE_AUTOCONF_ROOT is %s" % project_root)

        # TODO (nlopezgi): validate _AUTOCONF_ROOT points to a valid Bazel project
        use_default_project = False
        if not project_root:
            fail(("%s env variable must be set for rbe_autoconfig " +
                  "to function properly when export_configs is True " +
                  "or config_repos are set") % AUTOCONF_ROOT)
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
    ctx.file("rename_build_files.sh", "find ./test -name \"BUILD\" -exec sh -c 'mv \"$1\" \"$(dirname $1)/test.BUILD\"' _ {} \;", True)
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
