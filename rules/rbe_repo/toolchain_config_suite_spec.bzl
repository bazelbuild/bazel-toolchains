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
"""Utils for manipulating toolchain_config_suite_spec structs.

In order to export configs, rbe_autoconfig requires an
toolchain_config_suite_spec with the following sample dict:

YOUR_TOOLCHAIN_CONFIG_SUITE_SPEC = {
    "repo_name": "toolchain_config_host", # The name of the bazel external repo that hosts configs
    "output_base": "configs/test_configs", # The relative path under the root of external repo where
                                           # toolchain configs are hosted
    "container_repo": "google/bazel",      # The repo where container for this config is pulled from
    "container_registry": "marketplace.gcr.io", # The registry where container for this config is pulled from
    "default_java_home": "/usr/lib/jvm/java-8-openjdk-amd64" # Optional. The default java_home to use
    "toolchain_config_suite_autogen_spec": TOOLCHAIN_CONFIG_AUTOGEN_SPEC,
}

The last field in this dict must point to the TOOLCHAIN_CONFIG_AUTOGEN_SPEC definition
in a versions.bzl file that is located in the 'output_base' of the 'repo_name'.

This file will be read when a user wants to use checked-in configs.
It will be modified when a user wants to generate and export to the
output_base configs to be later on used as checked-in configs.

The versions.bzl file should (initially) contain exactly these definitions:

---- COPY LINES BELOW TO YOUR EMPTY versions.bzl FILE ----

_TOOLCHAIN_CONFIG_SPECS = []

_DEFAULT_TOOLCHAIN_CONFIG_SPEC = ""

# A map from supported Bazel versions mapped to supported config_spec names.
_BAZEL_TO_CONFIG_SPEC_NAMES = {}

# sha256 digest of the latest version of the toolchain container.
LATEST = ""

# Map from sha256 of the toolchain container to corresponding config_spec names.
CONTAINER_TO_CONFIG_SPEC_NAMES = {}

TOOLCHAIN_CONFIG_AUTOGEN_SPEC = struct(
    bazel_to_config_spec_names_map = _BAZEL_TO_CONFIG_SPEC_NAMES,
    container_to_config_spec_names_map = CONTAINER_TO_CONFIG_SPEC_NAMES,
    default_toolchain_config_spec = _DEFAULT_TOOLCHAIN_CONFIG_SPEC,
    latest_container = LATEST,
    toolchain_config_specs = _TOOLCHAIN_CONFIG_SPECS,
)

--- END OF COPY LINES BELOW TO YOUR EMPTY versions.bzl FILE ----

You can then load the versions.bzl file into the location where
you are declaring YOUR_RBE_REPO.

This bzl file also provides utils to convert fields of the
toolchain_config_suite_autogen_spec structs in the versions.bzl to a format that can be passed
to the _rbe_autoconfig_impl. This is because we cannot pass
structs to _rbe_autoconfig_impl.
Defs 'config_to_string_lists' and 'string_lists_to_config' in this file
provide a way to convert an toolchain_config_specs in the toolchain_config_suite_autogen_spec
from structs to lists and from lists to structs.
"""

load(
    "//configs/ubuntu16_04_clang:versions.bzl",
    toolchain_config_suite_autogen_spec = "TOOLCHAIN_CONFIG_AUTOGEN_SPEC",
)

_SEPARATOR = ":::"

REPO_SPEC_STRING_KEYS = [
    "container_repo",
    "container_registry",
    "output_base",
    "repo_name",
]

REPO_SPEC_KEYS = REPO_SPEC_STRING_KEYS + ["toolchain_config_suite_autogen_spec"]

REPO_SPEC_ALL_KEYS = REPO_SPEC_KEYS + ["default_java_home"]

CONFIG_SPEC_FIELDS = [
    "bazel_to_config_spec_names_map",
    "container_to_config_spec_names_map",
    "default_toolchain_config_spec",
    "latest_container",
    "toolchain_config_specs",
]

def default_toolchain_config_suite_spec():
    return {
        "repo_name": "bazel_toolchains",
        "output_base": "configs/ubuntu16_04_clang",
        "container_repo": "google/rbe-ubuntu16-04",
        "container_registry": "marketplace.gcr.io",
        "default_java_home": "/usr/lib/jvm/java-8-openjdk-amd64",
        "toolchain_config_suite_autogen_spec": toolchain_config_suite_autogen_spec,
    }

def validate_toolchain_config_suite_spec(name, toolchain_config_suite_spec):
    """ Validates the given toolchain_config_suite_spec is 

Should only be called from the rbe_autoconfig macro
in //rules/rbe_repo.bzl

    Args:
      name: Name of the rbe_autoconfig rule
      toolchain_config_suite_spec: The toolchain_config_suite_spec to validate

    """
    _validate_repo_spec_keys(name, toolchain_config_suite_spec)
    _validate_toolchain_config_suite_autogen_spec(name, toolchain_config_suite_spec)

# Validates the toolchain_config_suite_spec is a struct and has all required top level keys
def _validate_repo_spec_keys(name, toolchain_config_suite_spec):
    if type(toolchain_config_suite_spec) != "dict":
        fail("toolchain_config_suite_spec in %s is not a dict: '%s'" % (name, toolchain_config_suite_spec))
    for key in REPO_SPEC_KEYS:
        if not toolchain_config_suite_spec.get(key):
            fail("toolchain_config_suite_spec in %s does not contain required key '%s'" % (name, key))
    for key in toolchain_config_suite_spec.keys():
        if key not in REPO_SPEC_ALL_KEYS:
            fail("toolchain_config_suite_spec in %s contain unnecessary key '%s'" % (name, key))

    for key in REPO_SPEC_STRING_KEYS:
        _check_type(
            name = name,
            expected_type = "string",
            error_detail = ("It declares a '%s'" % key),
            object_to_check = toolchain_config_suite_spec[key],
        )
    if toolchain_config_suite_spec.get("default_toolchain_config_spec"):
        _check_type(
            name = name,
            expected_type = "string",
            error_detail = "It declares a 'default_toolchain_config_spec'",
            object_to_check = toolchain_config_suite_spec["default_toolchain_config_spec"],
        )

def _validate_toolchain_config_suite_autogen_spec(name, toolchain_config_suite_spec):
    _check_type(
        name = name,
        expected_type = "struct",
        error_detail = "It declares a 'toolchain_config_suite_autogen_spec'",
        object_to_check = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"],
    )

    # validate the toolchain_config_suite_autogen_spec object is a struct with all required fields
    for field in CONFIG_SPEC_FIELDS:
        if not hasattr(toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"], field):
            fail(("toolchain_config_suite_spec[\"toolchain_config_suite_autogen_spec\"] in %s does not contain " +
                  "required field '%s'") % (name, field))
    _validate_default_toolchain_config_spec(name, toolchain_config_suite_spec)
    _validate_bazel_to_config_spec_names_map(name, toolchain_config_suite_spec)
    _validate_container_to_config_spec_names_map(name, toolchain_config_suite_spec)
    _validate_configs(name, toolchain_config_suite_spec)

def _validate_default_toolchain_config_spec(name, toolchain_config_suite_spec):
    if toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].default_toolchain_config_spec != "":
        _check_type(
            name = name,
            expected_type = "struct",
            error_detail = "It declares a 'default_toolchain_config_spec'",
            object_to_check = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].default_toolchain_config_spec,
        )
    if toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].default_toolchain_config_spec != "":
        _validate_config_version_spec(name, toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].default_toolchain_config_spec)

    # Check the default config is in the list of configs
    if (toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].default_toolchain_config_spec != "" and
        toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].default_toolchain_config_spec not in toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].toolchain_config_specs):
        fail(("%s has a toolchain_config_suite_spec[\"toolchain_config_suite_autogen_spec\"] field 'default_toolchain_config_spec' " +
              "with value '%s' that is not in the 'toolchain_config_specs' list: '%s'. " +
              "'%s' was passed as value.") %
             (name, toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].default_toolchain_config_spec, toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].toolchain_config_specs))

def _validate_bazel_to_config_spec_names_map(name, toolchain_config_suite_spec):
    _check_type(
        name = name,
        expected_type = "dict",
        error_detail = "It declares a 'bazel_to_config_spec_names_map'",
        object_to_check = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map,
    )
    for value in toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].bazel_to_config_spec_names_map.values():
        _check_type(
            name = name,
            expected_type = "list",
            error_detail = "It declares a 'bazel_to_config_spec_names_map' value",
            object_to_check = value,
        )

def _validate_container_to_config_spec_names_map(name, toolchain_config_suite_spec):
    _check_type(
        name = name,
        expected_type = "dict",
        error_detail = "It declares a 'container_to_config_spec_names_map'",
        object_to_check = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map,
    )
    for value in toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map.values():
        _check_type(
            name = name,
            expected_type = "list",
            error_detail = "It declares a 'container_to_config_spec_names_map' value",
            object_to_check = value,
        )
    for key in toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map.keys():
        if not key.startswith("sha256:"):
            fail(("%s has a toolchain_config_suite_spec[\"toolchain_config_suite_autogen_spec\"] field 'container_to_config_spec_names_map' " +
                  "that has a key that is not a valid image sha that starts with 'sha256:'. " +
                  "'%s' was passed as value.") %
                 (name, toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map))
    if (toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container != "" and
        not toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container.startswith("sha256:")):
        fail(("%s has a toolchain_config_suite_spec[\"toolchain_config_suite_autogen_spec\"] field 'latest_container' " +
              "that is neither an empty string or a valid sha of an image that " +
              "starts with 'sha256:'. '%s' was passed as value.") %
             (name, toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container))
    if (toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container != "" and
        toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map != {} and
        toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container not in toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map.keys()):
        fail(("%s has a toolchain_config_suite_spec[\"toolchain_config_suite_autogen_spec\"] field 'latest_container' " +
              "with value '%s', which is not a key in the " +
              "container_to_config_spec_names_map '%s'") %
             (name, toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container, toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map))

def _validate_configs(name, toolchain_config_suite_spec):
    # Validate all configs in toolchain_config_specs
    _check_type(
        name = name,
        expected_type = "list",
        error_detail = "It declares a 'toolchain_config_specs'",
        object_to_check = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].toolchain_config_specs,
    )
    for config_version_spec in toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].toolchain_config_specs:
        _validate_config_version_spec(name, config_version_spec)

def _validate_config_version_spec(name, config_version_spec):
    """Validates a single config_version_spec """
    _check_type(
        name = name,
        expected_type = "struct",
        error_detail = "It declares a 'config_version_spec'",
        object_to_check = config_version_spec,
    )
    required_fields = [
        "name",
        "java_home",
        "create_java_configs",
        "create_cc_configs",
        "config_repos",
        "env",
    ]
    for field in required_fields:
        if not hasattr(config_version_spec, field):
            fail(("%s has a toolchain_config_suite_spec[\"toolchain_config_suite_autogen_spec\"] field that " +
                  "includes '%s' that is not a valid config_version_spec " +
                  "as its missing field '%s'. ") %
                 (name, config_version_spec, field))
    error_detail_prefix = (("It declares '%s', that is not a valid config_version_spec as has ") %
                           (config_version_spec))
    _check_type(
        name = name,
        expected_type = "string",
        error_detail = error_detail_prefix + "a name",
        object_to_check = config_version_spec.name,
    )
    _check_type(
        name = name,
        expected_type = "string" if config_version_spec.create_java_configs else "NoneType",
        error_detail = error_detail_prefix + "a java_home",
        object_to_check = config_version_spec.java_home,
    )
    _check_type(
        name = name,
        expected_type = "bool",
        error_detail = error_detail_prefix + "a create_java_configs",
        object_to_check = config_version_spec.create_java_configs,
    )
    _check_type(
        name = name,
        expected_type = "bool",
        error_detail = error_detail_prefix + "a create_cc_configs",
        object_to_check = config_version_spec.create_cc_configs,
    )
    _check_type(
        name = name,
        expected_type = "list",
        error_detail = error_detail_prefix + "a config_repos",
        object_to_check = config_version_spec.config_repos,
    )
    for config_repo_entry in config_version_spec.config_repos:
        _check_type(
            name = name,
            expected_type = "string",
            error_detail = error_detail_prefix + "a config_repos that has an item",
            object_to_check = config_repo_entry,
        )
    _check_type(
        name = name,
        expected_type = "dict",
        error_detail = error_detail_prefix + "an env",
        object_to_check = config_version_spec.env,
    )
    for key in config_version_spec.env.keys():
        _check_type(
            name = name,
            expected_type = "string",
            error_detail = error_detail_prefix + "an env that has a key",
            object_to_check = key,
        )
    for value in config_version_spec.env.values():
        _check_type(
            name = name,
            expected_type = "string",
            error_detail = error_detail_prefix + "an env that has a value",
            object_to_check = value,
        )

def config_to_string_lists(toolchain_config_specs):
    """Creates a struct with lists from the given toolchain_config_specs

    Args:
      toolchain_config_specs: List with structs. Each represents a repo config
      with 'name' (str), 'java_home'(str), 'create_java_configs' (bool),
      'create_cc_configs' (bool). 'config_repos' (string list) and 'env' (dict).

    Returns:
      A struct with all lists containing data from toolchain_config_specs.
    """
    names = []
    java_home = []
    create_java_configs = []
    create_cc_configs = []
    config_repos = []
    env_keys = []
    env_values = []

    for toolchain_config_spec in toolchain_config_specs:
        names += [toolchain_config_spec.name]
        java_home += [toolchain_config_spec.java_home]
        create_java_configs += ["non_empty" if toolchain_config_spec.create_java_configs else ""]
        create_cc_configs += ["non_empty" if toolchain_config_spec.create_cc_configs else ""]
        config_repos += [_SEPARATOR.join(toolchain_config_spec.config_repos)]
        env_keys += [_SEPARATOR.join(toolchain_config_spec.env.keys())]

        # Error out if any of the env values contains the separator
        for env_val in toolchain_config_spec.env.values():
            if len(env_val.split(_SEPARATOR)) > 1:
                fail(("rbe_autoconfig encountered an error processing '%s', '%s' " +
                      "was set as value for an environment key. This value " +
                      "includes '%s' which is unsupported in rbe_autoconfig") %
                     (str(toolchain_config_specs), env_val, _SEPARATOR))
        env_values += [_SEPARATOR.join(toolchain_config_spec.env.values())]

    return struct(
        names = names,
        java_home = java_home,
        create_java_configs = create_java_configs,
        create_cc_configs = create_cc_configs,
        config_repos = config_repos,
        env_keys = env_keys,
        env_values = env_values,
    )

def string_lists_to_config(ctx, requested_toolchain_config_spec_name, java_home):
    """Creates a list of structs with repo configs

    Args:
      ctx: the Bazel context object.
      requested_toolchain_config_spec_name: provided/selected name for the configs
      java_home: The provided/selected location of java_home.

    Returns:
      A list with structs, each an repo config with 'name'
      (str), 'java_home'(str), 'create_java_configs' (bool),
      'create_cc_configs' (bool). 'config_repos' (string list)
      and 'env' (dict).
    """
    new_config = True
    configs = []
    env_list = []
    index = 0
    for toolchain_config_spec_name in ctx.attr.configs_obj_names:
        config_repos = ctx.attr.configs_obj_config_repos[index].split(_SEPARATOR)
        if config_repos == [""]:
            config_repos = []
        env_keys = ctx.attr.configs_obj_env_keys[index].split(_SEPARATOR)
        env_values = ctx.attr.configs_obj_env_values[index].split(_SEPARATOR)
        if env_keys == [""]:
            env_keys = []
        env_tuples = []
        env_index = 0
        for key in env_keys:
            env_tuples += [(key, env_values[env_index])]
            env_index += 1
        config = struct(
            name = toolchain_config_spec_name,
            java_home = ctx.attr.configs_obj_java_home[index] if ctx.attr.configs_obj_java_home and ctx.attr.configs_obj_java_home[index] else None,
            create_java_configs = True if ctx.attr.configs_obj_create_java_configs[index] else False,
            create_cc_configs = True if ctx.attr.configs_obj_create_cc_configs[index] else False,
            config_repos = config_repos,
            env = dict(env_tuples),
        )
        configs += [config]
        if toolchain_config_spec_name == requested_toolchain_config_spec_name:
            new_config = False
            _check_config(ctx, config)
        index += 1

    # If the config provided/selected is not in the existing ones, add it
    if new_config:
        configs += [struct(
            name = requested_toolchain_config_spec_name,
            java_home = java_home,
            create_java_configs = ctx.attr.create_java_configs,
            create_cc_configs = ctx.attr.create_cc_configs,
            config_repos = ctx.attr.config_repos,
            env = ctx.attr.env,
        )]
    return configs

# Fail if the config defined by the user in the ctx/selected by default
# does not match details of the one in versions.bzl
def _check_config(ctx, config):
    if ctx.attr.env != config.env:
        fail(("%s failed. '%s' was passed as env and '%s' was " +
              "provided/selected as toolchain_config_spec_name but the provided/selected " +
              "toolchain_config_specs had set '%s' as env. Either set the env attr " +
              "properly in the rule or set a different toolchain_config_spec_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.env), config.name, str(config.env)))

    if ctx.attr.config_repos != config.config_repos:
        fail(("%s failed. '%s' was passed as config_repos and '%s' was " +
              "provided/selected as toolchain_config_spec_name but the provided/selected " +
              "toolchain_config_specs had set '%s' as config_repos. Either set " +
              "the config_repos attr properly in the rule or set a different " +
              "toolchain_config_spec_name explicitly") % (ctx.attr.name, str(ctx.attr.config_repos), config.name, str(config.config_repos)))

    if ctx.attr.create_java_configs != config.create_java_configs:
        fail(("%s failed. '%s' was passed as create_java_configs and '%s' was " +
              "provided/selected as toolchain_config_spec_name but the provided/selected " +
              "toolchain_config_specs had set '%s' as create_java_configs. " +
              "Either set the create_java_configs attr " +
              "properly in the rule or set a different toolchain_config_spec_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.create_java_configs), config.name, str(config.create_java_configs)))

    if ctx.attr.create_cc_configs != config.create_cc_configs:
        fail(("%s failed. '%s' was passed as create_cc_configs and '%s' was " +
              "provided/selected as toolchain_config_spec_name but the provided/selected " +
              "toolchain_config_specs had set '%s' as create_cc_configs. " +
              "Either set the create_cc_configs attr " +
              "properly in the rule or set a different toolchain_config_spec_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.create_cc_configs), config.name, str(config.create_cc_configs)))

def _check_type(
        name,
        error_detail,
        expected_type,
        object_to_check):
    if type(object_to_check) != expected_type:
        fail(("{name} has an invalid toolchain_config_suite_spec[\"toolchain_config_suite_autogen_spec\"]. " +
              "{error_detail} that is not a {expected_type}. " +
              "Expected '{expected_type}' but got '{actual_type}'").format(
            actual_type = type(object_to_check),
            error_detail = error_detail,
            expected_type = expected_type,
            name = name,
        ))
