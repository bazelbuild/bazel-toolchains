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
"""Utils for manipulating rbe_repo_spec structs.

In order to export configs, rbe_autoconfig requires an
rbe_repo_spec with the following sample dict:

MY_RBE_REPO = {
    "repo_name": "toolchain_config_host", # The name of the bazel external repo that hosts configs
    "output_base": "configs/test_configs", # The absolute path under the root of external repo where
                                           # toolchain configs are hosted
    "container_repo": "google/bazel",      # The repo where container for this config are pulled from
    "container_registry": "marketplace.gcr.io", # The registry where container for this config are pulled from
    "rbe_repo_gen_spec": rbe_repo_gen_spec(),
}

The last field in this dict must point to the rbe_repo_gen_spec()  definition
in a versions.bzl file that is located in the 'output_base' of the 'repo_name'.

This file will be read when a user wants to use checked-in configs.
It will be modified when a user wants to generate and export to the
output_base configs to be later on used as checked-in configs.

The versions.bzl file should (initially) contain exactly these definitions:

def configs():
    return []

DEFAULT_TOOLCHAIN_CONFIG_SPEC = ""

# Returns a dict with suppported Bazel versions mapped to the config version to use.
def bazel_to_config_versions():
    return {
    }

# sha256 digest of the latest version of the toolchain container.
LATEST = ""

# Map from sha256 of the toolchain container to corresponding major container
# versions.
def container_to_config_spec_names():
    return {
    }

def rbe_repo_gen_spec():
    return struct(
        bazel_to_config_spec_names_map = bazel_to_config_versions,
        container_to_config_spec_names_map = container_to_config_spec_names,
        default_toolchain_config_spec = DEFAULT_TOOLCHAIN_CONFIG_SPEC,
        latest_container = LATEST,
        toolchain_config_specs = configs,
    )


This bzl file also provides utils to convert fields of the
rbe_repo_gen_spec structs in the versions.bzl to a format that can be passed
to the _rbe_autoconfig_impl. This is because we cannot pass
structs to _rbe_autoconfig_impl. 
Defs 'config_to_string_lists' and 'string_lists_to_config' in this file
provide a way to convert an toolchain_config_specs in the rbe_repo_gen_spec
from structs to lists and from lists to structs.
"""

# TODO(nlopezgi): move to using versions.bzl
# once migration for toolchain config release process is complete
load(
    "//configs/ubuntu16_04_clang:versions_to_migrate.bzl",
    "rbe_repo_gen_spec",
)

_SEPARATOR = ":::"

REPO_SPEC_KEYS = [
    "container_repo",
    "container_registry",
    "output_base",
    "repo_name",
    "rbe_repo_gen_spec",
]

CONFIG_SPEC_FIELDS = [
    "bazel_to_config_spec_names_map",
    "container_to_config_spec_names_map",
    "default_toolchain_config_spec",
    "latest_container",
    "toolchain_config_specs",
]

def default_rbe_repo_spec():
    return {
        "repo_name": "bazel_toolchains",
        "output_base": "configs/ubuntu16_04_clang",
        "container_repo": "google/rbe-ubuntu16-04",
        "container_registry": "marketplace.gcr.io",
        "rbe_repo_gen_spec": rbe_repo_gen_spec(),
    }

def validate_rbe_repo_spec(name, rbe_repo_spec):
    """ Validates the given rbe_repo_spec is 

Should only be called from the rbe_autoconfig macro
in //rules/rbe_repo.bzl

    Args:
      name: Name of the rbe_autoconfig rule
      rbe_repo_spec: The rbe_repo_spec to validate

    """
    _validate_repo_spec_keys(name, rbe_repo_spec)
    _validate_rbe_repo_gen_spec(name, rbe_repo_spec)

# Validates the rbe_repo_spec is a struct and has all required top level keys
def _validate_repo_spec_keys(name, rbe_repo_spec):
    if type(rbe_repo_spec) != "dict":
        fail("rbe_repo_spec in %s is not a dict: '%s'" % (name, rbe_repo_spec))
    for key in REPO_SPEC_KEYS:
        if not rbe_repo_spec.get(key):
            fail("rbe_repo_spec in %s does not contain required key '%s'" % (name, key))
    for key in rbe_repo_spec.keys():
        if key not in REPO_SPEC_KEYS:
            fail("rbe_repo_spec in %s contain unnecessary key '%s'" % (name, key))

def _validate_rbe_repo_gen_spec(name, rbe_repo_spec):
    if str(type(rbe_repo_spec["rbe_repo_gen_spec"])) != "struct":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] that is not a struct " +
              "'%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"]))

    # validate the rbe_repo_gen_spec object is a struct with all required fields
    for field in CONFIG_SPEC_FIELDS:
        if not hasattr(rbe_repo_spec["rbe_repo_gen_spec"], field):
            fail(("rbe_repo_spec[\"rbe_repo_gen_spec\"] in %s does not contain " +
                  "required field '%s'") % (name, field))
    _validate_default_toolchain_config_spec(name, rbe_repo_spec)
    _validate_bazel_to_config_spec_names_map(name, rbe_repo_spec)
    _validate_container_to_config_spec_names_map(name, rbe_repo_spec)
    _validate_configs(name, rbe_repo_spec)

def _validate_default_toolchain_config_spec(name, rbe_repo_spec):
    if (rbe_repo_spec["rbe_repo_gen_spec"].default_toolchain_config_spec != "" and
        type(rbe_repo_spec["rbe_repo_gen_spec"].default_toolchain_config_spec) != "struct"):
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'default_toolchain_config_spec' " +
              "that is not either an empty string or a 'struct'. " +
              "'%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].default_toolchain_config_spec))
    if rbe_repo_spec["rbe_repo_gen_spec"].default_toolchain_config_spec != "":
        _validate_config_version_spec(name, rbe_repo_spec["rbe_repo_gen_spec"].default_toolchain_config_spec)

    # Check the default config is in the list of configs
    if (rbe_repo_spec["rbe_repo_gen_spec"].default_toolchain_config_spec != "" and
        rbe_repo_spec["rbe_repo_gen_spec"].default_toolchain_config_spec not in rbe_repo_spec["rbe_repo_gen_spec"].toolchain_config_specs()):
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'default_toolchain_config_spec' " +
              "with value '%s' that is not in the 'toolchain_config_specs' list: '%s'. " +
              "'%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].default_toolchain_config_spec, rbe_repo_spec["rbe_repo_gen_spec"].toolchain_config_specs()))

def _validate_bazel_to_config_spec_names_map(name, rbe_repo_spec):
    if type(rbe_repo_spec["rbe_repo_gen_spec"].bazel_to_config_spec_names_map) != "function":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'bazel_to_config_spec_names_map' " +
              "that is not a function. '%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].bazel_to_config_spec_names_map))
    if type(rbe_repo_spec["rbe_repo_gen_spec"].bazel_to_config_spec_names_map()) != "dict":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'bazel_to_config_spec_names_map' " +
              "that does not return a map. '%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].bazel_to_config_spec_names_map))
    for value in rbe_repo_spec["rbe_repo_gen_spec"].bazel_to_config_spec_names_map().values():
        if type(value) != "list":
            fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'bazel_to_config_spec_names_map' " +
                  "that has a value that is not a list. '%s' was passed as value.") %
                 (name, rbe_repo_spec["rbe_repo_gen_spec"].bazel_to_config_spec_names_map()))

def _validate_container_to_config_spec_names_map(name, rbe_repo_spec):
    if type(rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map) != "function":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'container_to_config_spec_names_map' " +
              "that is not a function. '%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map))
    if type(rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map()) != "dict":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'container_to_config_spec_names_map' " +
              "that does not return a map. '%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map()))
    for value in rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map().values():
        if type(value) != "list":
            fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'container_to_config_spec_names_map' " +
                  "that has a value that is not a list. '%s' was passed as value.") %
                 (name, rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map()))
    for key in rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map().keys():
        if not key.startswith("sha256:"):
            fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'container_to_config_spec_names_map' " +
                  "that has a key that is not a valid image sha that starts with 'sha256:'. " +
                  "'%s' was passed as value.") %
                 (name, rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map()))
    if (rbe_repo_spec["rbe_repo_gen_spec"].latest_container != "" and
        not rbe_repo_spec["rbe_repo_gen_spec"].latest_container.startswith("sha256:")):
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'latest_container' " +
              "that is not either an empty string or a valid sha of an image that " +
              "starts with 'sha256:'. '%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].latest_container))
    if (rbe_repo_spec["rbe_repo_gen_spec"].latest_container != "" and
        rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map() != {} and
        rbe_repo_spec["rbe_repo_gen_spec"].latest_container not in rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map().keys()):
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'latest_container' " +
              "with value '%s', which is not a key in the " +
              "container_to_config_spec_names_map '%s'") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].latest_container, rbe_repo_spec["rbe_repo_gen_spec"].container_to_config_spec_names_map()))

def _validate_configs(name, rbe_repo_spec):
    # Validate all configs in toolchain_config_specs
    if type(rbe_repo_spec["rbe_repo_gen_spec"].toolchain_config_specs) != "function":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'toolchain_config_specs' " +
              "that is not a function. '%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].toolchain_config_specs))
    if type(rbe_repo_spec["rbe_repo_gen_spec"].toolchain_config_specs()) != "list":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field 'toolchain_config_specs' " +
              "that does not return a list. '%s' was passed as value.") %
             (name, rbe_repo_spec["rbe_repo_gen_spec"].toolchain_config_specs))

    for config_version_spec in rbe_repo_spec["rbe_repo_gen_spec"].toolchain_config_specs():
        _validate_config_version_spec(name, config_version_spec)

def _validate_config_version_spec(name, config_version_spec):
    """Validates a single config_version_spec """
    if type(config_version_spec) != "struct":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
              "includes '%s' that is not a valid config_version_spec " +
              "of type 'struct'. ") %
             (name, config_version_spec))
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
            fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
                  "includes '%s' that is not a valid config_version_spec " +
                  "as its missing field '%s'. ") %
                 (name, config_version_spec, field))
    if (type(config_version_spec.name) != "string"):
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
              "includes '%s' that is not a valid config_version_spec " +
              "as has a name that is not a string. ") %
             (name, config_version_spec))
    if type(config_version_spec.java_home) != "string":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
              "includes '%s' that is not a valid config_version_spec " +
              "as has a java_home that is not a string. ") %
             (name, config_version_spec))
    if type(config_version_spec.create_java_configs) != "bool":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
              "includes '%s' that is not a valid config_version_spec " +
              "as has a create_java_configs that is not a bool.") %
             (name, config_version_spec))
    if type(config_version_spec.create_cc_configs) != "bool":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
              "includes '%s' that is not a valid config_version_spec " +
              "as has a create_cc_configs that is not a bool.") %
             (name, config_version_spec))
    if type(config_version_spec.config_repos) != "list":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
              "includes '%s' that is not a valid config_version_spec " +
              "as has a config_repos that is not a list.") %
             (name, config_version_spec))
    for config_repo_entry in config_version_spec.config_repos:
        if type(config_repo_entry) != "string":
            fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
                  "includes '%s' that is not a valid config_version_spec " +
                  "as has a config_repos that has an item that is not a string.") %
                 (name, config_version_spec))
    if type(config_version_spec.env) != "dict":
        fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
              "includes '%s' that is not a valid config_version_spec " +
              "as has an env that is not a dict.") %
             (name, config_version_spec))
    for key in config_version_spec.env.keys():
        if type(key) != "string":
            fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
                  "includes '%s' that is not a valid config_version_spec " +
                  "as has an env that has a key that is not a string.") %
                 (name, config_version_spec))
    for value in config_version_spec.env.values():
        if type(value) != "string":
            fail(("%s has a rbe_repo_spec[\"rbe_repo_gen_spec\"] field that " +
                  "includes '%s' that is not a valid config_version_spec " +
                  "as has an env that has a value that is not a string.") %
                 (name, config_version_spec))

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
            java_home = ctx.attr.configs_obj_java_home[index],
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
    if not ctx.attr.env == config.env:
        fail(("%s failed. '%s' was passed as env and '%s' was " +
              "provided/selected as toolchain_config_spec_name but the provided/selected " +
              "toolchain_config_specs had set '%s' as env. Either set the env attr " +
              "properly in the rule or set a different toolchain_config_spec_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.env), config.name, str(config.env)))

    if not ctx.attr.config_repos == config.config_repos:
        fail(("%s failed. '%s' was passed as config_repos and '%s' was " +
              "provided/selected as toolchain_config_spec_name but the provided/selected " +
              "toolchain_config_specs had set '%s' as config_repos. Either set " +
              "the config_repos attr properly in the rule or set a different " +
              "toolchain_config_spec_name explicitly") % (ctx.attr.name, str(ctx.attr.config_repos), config.name, str(config.config_repos)))

    if not ctx.attr.create_java_configs == config.create_java_configs:
        fail(("%s failed. '%s' was passed as create_java_configs and '%s' was " +
              "provided/selected as toolchain_config_spec_name but the provided/selected " +
              "toolchain_config_specs had set '%s' as create_java_configs. " +
              "Either set the create_java_configs attr " +
              "properly in the rule or set a different toolchain_config_spec_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.create_java_configs), config.name, str(config.create_java_configs)))

    if not ctx.attr.create_cc_configs == config.create_cc_configs:
        fail(("%s failed. '%s' was passed as create_cc_configs and '%s' was " +
              "provided/selected as toolchain_config_spec_name but the provided/selected " +
              "toolchain_config_specs had set '%s' as create_cc_configs. " +
              "Either set the create_cc_configs attr " +
              "properly in the rule or set a different toolchain_config_spec_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.create_cc_configs), config.name, str(config.create_cc_configs)))
