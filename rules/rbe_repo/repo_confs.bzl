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
"""Utils for manipulating repo_config structs.

repo_conf structs in generated versions.bzl file cannot be passed as
structs to _rbe_autoconfig_impl.

defs in this file provide a way to convert repo_conf (+ env directories)
from structs to lists and from lists to structs.
"""

_SEPARATOR = ":::"

def config_to_string_lists(rbe_repo_configs):
    """Creates a struct with lists from the given rbe_repo_configs

    Args:
      rbe_repo_configs: List with structs. Each represents a repo config
      with 'name' (str), 'java_home'(str), 'create_java_configs' (bool),
      'create_cc_configs' (bool). 'config_repos' (string list) and 'env' (dict).

    Returns:
      A struct with all lists containing data from rbe_repo_configs.
    """
    names = []
    java_home = []
    create_java_configs = []
    create_cc_configs = []
    config_repos = []
    env_keys = []
    env_values = []

    for repo_config in rbe_repo_configs:
        names += [repo_config.name]
        java_home += [repo_config.java_home]
        create_java_configs += ["non_empty" if repo_config.create_java_configs else ""]
        create_cc_configs += ["non_empty" if repo_config.create_cc_configs else ""]
        config_repos += [_SEPARATOR.join(repo_config.config_repos)]
        env_keys += [_SEPARATOR.join(repo_config.env.keys())]

        # Error out if any of the env values contains the separator
        for env_val in repo_config.env.values():
            if len(env_val.split(_SEPARATOR)) > 1:
                fail(("rbe_autoconfig encountered an error processing '%s', '%s' " +
                      "was set as value for an environment key. This value " +
                      "includes '%s' which is unsupported in rbe_autoconfig") %
                     (str(rbe_repo_configs), env_val, _SEPARATOR))
        env_values += [_SEPARATOR.join(repo_config.env.values())]

    return struct(
        names = names,
        java_home = java_home,
        create_java_configs = create_java_configs,
        create_cc_configs = create_cc_configs,
        config_repos = config_repos,
        env_keys = env_keys,
        env_values = env_values,
    )

def string_lists_to_config(ctx, requested_config_name, java_home):
    """Creates a list of structs with repo configs

    Args:
      ctx: the Bazel context object.
      requested_config_name: provided/selected name for the configs
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
    for config_name in ctx.attr.configs_obj_names:
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
            name = config_name,
            java_home = ctx.attr.configs_obj_java_home[index],
            create_java_configs = True if ctx.attr.configs_obj_create_java_configs[index] else False,
            create_cc_configs = True if ctx.attr.configs_obj_create_cc_configs[index] else False,
            config_repos = config_repos,
            env = dict(env_tuples),
        )
        configs += [config]
        if config_name == requested_config_name:
            new_config = False
            _check_config(ctx, config)
        index += 1

    # If the config provided/selected is not in the existing ones, add it
    if new_config:
        configs += [struct(
            name = requested_config_name,
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
              "provided/selected as config_name but the provided/selected " +
              "rbe_repo_configs had set '%s' as env. Either set the env attr " +
              "properly in the rule or set a different config_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.env), config.name, str(config.env)))

    if not ctx.attr.config_repos == config.config_repos:
        fail(("%s failed. '%s' was passed as config_repos and '%s' was " +
              "provided/selected as config_name but the provided/selected " +
              "rbe_repo_configs had set '%s' as config_repos. Either set " +
              "the config_repos attr properly in the rule or set a different " +
              "config_name explicitly") % (ctx.attr.name, str(ctx.attr.config_repos), config.name, str(config.config_repos)))

    if not ctx.attr.create_java_configs == config.create_java_configs:
        fail(("%s failed. '%s' was passed as create_java_configs and '%s' was " +
              "provided/selected as config_name but the provided/selected " +
              "rbe_repo_configs had set '%s' as create_java_configs. " +
              "Either set the create_java_configs attr " +
              "properly in the rule or set a different config_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.create_java_configs), config.name, str(config.create_java_configs)))

    if not ctx.attr.create_cc_configs == config.create_cc_configs:
        fail(("%s failed. '%s' was passed as create_cc_configs and '%s' was " +
              "provided/selected as config_name but the provided/selected " +
              "rbe_repo_configs had set '%s' as create_cc_configs. " +
              "Either set the create_cc_configs attr " +
              "properly in the rule or set a different config_name " +
              "explicitly") % (ctx.attr.name, str(ctx.attr.create_cc_configs), config.name, str(config.create_cc_configs)))
