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
"""Exposes def to valiate if checked-in confs can be used in rbe_autoconf."""

CHECKED_IN_CONFS_TRY = "Try"
CHECKED_IN_CONFS_FORCE = "Force"
CHECKED_IN_CONFS_FALSE = "False"
CHECKED_IN_CONFS_VALUES = [
    CHECKED_IN_CONFS_TRY,
    CHECKED_IN_CONFS_FORCE,
    CHECKED_IN_CONFS_FALSE,
]

def validateUseOfCheckedInConfigs(
        name,
        base_container_digest,
        bazel_version,
        bazel_rc_version,
        config_repos,
        create_cc_configs,
        detect_java_home,
        digest,
        env,
        java_home,
        toolchain_config_suite_spec,
        registry,
        repository,
        requested_toolchain_config_spec_name,
        tag,
        use_checked_in_confs):
    """Check if checked-in configs are available and should be used.

    Finds if a C/C++ toolchain config has already been checked-in to
    the external repo defined by the toolchain_config_suite_spec. Configs
    are matched by Bazel version, container used to build the configs,
    and env variables for C/C++ toolchain configuration.
    If configs are found, return the toolchain_config_spec, and the digest
    of a container compatible with that config.

    Args:
      name: Name of the rule target.
      base_container_digest: SHA256 sum digest of the base image.
      bazel_version: Version string of the Bazel release.
      bazel_rc_version: The RC version of the Bazel release if the given
          Bazel release is a RC.
      config_repos: list of additional external repos corresponding to
          configure like repo rules that need to be produced in addition to
          local_config_cc.
      create_cc_configs: Optional. Specifies whether to generate C/C++ configs.
          Defauls to True.
      detect_java_home: if set to True checked-in configs will not be used
      digest: The digest of the container in which the configs are goings to
          be used.
      env: The environment dict.
      java_home: Path to the Java home.
      registry: The registry where the toolchain container can be found.
      toolchain_config_suite_spec: Dict containing values to identify a toolchain
          container + GitHub repo where configs are stored. Must
          include keys:
              'repo_name': name of the Bazel external repo containing
                  configs
              'output_base': relative location of the output base in the
                  GitHub repo where configs are located)
              'container_repo': repo for the base toolchain container
              'container_registry': registry for the base toolchain container
              'latest_container': sha of the latest container
          container_to_config_spec_names_map: Optional. Only required when export_configs
              is set. Set to point to def container_to_config_spec_names()
              defined in the versions.bzl file generated in the output_base defined
              in the toolchain_config_suite_spec.
          toolchain_config_specs: Must point to a list containing structs,
              each struct represents a repo config with 'name' (str),
             'java_home'(str), 'create_java_configs' (bool), 'create_cc_configs' (bool),
             'config_repos' (string list) and 'env' (dict).
          bazel_to_config_spec_names_map: Set to point to def bazel_to_config_versions()
              defined in the versions.bzl file generated in the output_base defined
              in the toolchain_config_suite_spec.
      repository: The path to the toolchain container on the registry.
      requested_toolchain_config_spec_name: the toolchain_config_spec_name of the config requested by the user.
      tag: The tag on the toolchain container.
      use_checked_in_confs: Whether to use checked in configs.

    Returns:
      The toolchain_config_spec if one was found
      The recommended digest for this toolchain_config_spec (might be
      overriden by rbe_repo if user if user requested a different one)
    """
    if use_checked_in_confs == CHECKED_IN_CONFS_FALSE:
        print("%s not using checked in configs as user set attr to 'False' " % name)
        return None, None
    if detect_java_home:
        print("%s not using checked in configs as detect_java_home was set to True " % name)
        return None, None
    if bazel_rc_version:
        print("%s not using checked in configs as bazel rc version was used " % name)
        return None, None

    if not base_container_digest:
        # If no base_container_digest was set we only use checked-in confs if
        # the registry and repo match the toolchain_config_suite_spec
        if registry and registry != toolchain_config_suite_spec["container_registry"]:
            print(("%s not using checked in configs; registry was set to '%s' " +
                   "and toolchain_config_suite_spec is configured for '%s'") %
                  (name, registry, toolchain_config_suite_spec["container_registry"]))
            return None, None
        if repository and repository != toolchain_config_suite_spec["container_repo"]:
            print(("%s not using checked in configs; repository was set to '%s' " +
                   "and toolchain_config_suite_spec is configured for '%s'") %
                  (name, repository, toolchain_config_suite_spec["container_repo"]))
            return None, None
    bazel_to_config_spec_names_map = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].bazel_to_config_spec_names_map
    if not bazel_to_config_spec_names_map.get(bazel_version):
        # TODO(nlopezgi): consider trying to fall back to 0.x.0 version if 0.x.y (y>0)
        print(("%s not using checked in configs; Bazel version %s " +
               "was picked/selected but no checked in config was " +
               "found in map %s") %
              (name, bazel_version, str(bazel_to_config_spec_names_map)))
        return None, None

    # Find a config for the given version of bazel
    bazel_compat_configs = bazel_to_config_spec_names_map.get(bazel_version)
    if not bazel_to_config_spec_names_map.get(bazel_version):
        print(("%s not using checked in configs; Bazel version %s was " +
               "picked/selected but no checked in config was found in map %s") %
              (name, bazel_version, str(bazel_to_config_spec_names_map)))
        return None, None

    # Try to resolve the digest with the base_container_digest or if latest was set as tag
    if base_container_digest:
        digest = base_container_digest
    if tag:  # Implies `digest` is not specified.
        if tag == "latest" and toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container != "":
            digest = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container
            # if any tag other than latest is used we will not use checked-in configs
            # (to not hardcode tag info anywhere in these rules)

        else:
            print(("%s not using checked in configs; tag (other than " +
                   "latest) was selected") % name)
            return None, None
    config = None
    container_to_config_spec_names_map = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].container_to_config_spec_names_map

    toolchain_config_specs = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].toolchain_config_specs

    # If a digest was provided/selected lets try to find a config that will work
    if digest:
        compatible_configs = container_to_config_spec_names_map.get(digest)
        if not compatible_configs:
            print(("%s not using checked in configs; digest '%s' was picked/selected " +
                   "but no compatible checked in config was found in " +
                   "map '%s'") % (name, digest, str(container_to_config_spec_names_map)))
            return None, None
        if requested_toolchain_config_spec_name and requested_toolchain_config_spec_name not in compatible_configs:
            print(("%s not using checked in configs; config with name '%s' was requested " +
                   "but was not found in '%s' compatible configs for the " +
                   "container with digest '%s'") %
                  (name, requested_toolchain_config_spec_name, compatible_configs, digest))
            return None, None

        # pick a config: first try the default
        if (toolchain_config_suite_spec.get("toolchain_config_suite_autogen_spec").default_toolchain_config_spec != "" and
            toolchain_config_suite_spec.get("toolchain_config_suite_autogen_spec").default_toolchain_config_spec.name in compatible_configs):
            config = toolchain_config_suite_spec.get("toolchain_config_suite_autogen_spec").default_toolchain_config_spec
        else:
            config = _get_config(compatible_configs[0], toolchain_config_specs)

    # If a config was requested or found via digest, lets see if its compatible with
    # the selected Bazel version
    if requested_toolchain_config_spec_name or config:
        if requested_toolchain_config_spec_name:
            config = _get_config(requested_toolchain_config_spec_name, toolchain_config_specs)
        if config and config.name not in bazel_compat_configs:
            print(("%s not using checked in configs; config %s was " +
                   "picked/selected, Bazel version %s was picked/selected " +
                   "but no checked in config was found in %s") %
                  (name, config, bazel_version, str(bazel_compat_configs)))
            return None, None

    # We have found a candiadate config, lets check if env / config_repos match
    if config and not _check_config(
        candidate_config = config,
        config_repos = config_repos,
        create_cc_configs = create_cc_configs,
        env = env,
        name = name,
    ):
        print(("%s not using checked in configs; '%s' was picked/selected as a candidate " +
               "matching config for Bazel %s from whose list of compatible configs are %s " +
               "but it does not match the 'env = %s', 'config_repos = %s', " +
               "and/or 'create_cc_configs = %s' passed as attrs") %
              (
                  name,
                  config,
                  bazel_version,
                  str(bazel_compat_configs),
                  env,
                  config_repos,
                  create_cc_configs,
              ))
        return None, None

    # If we have not found a config so far, pick one that will work for the
    # selected Bazel version
    if not config:
        for candidate_config in bazel_compat_configs:
            if _check_config(
                candidate_config = _get_config(candidate_config, toolchain_config_specs),
                config_repos = config_repos,
                create_cc_configs = create_cc_configs,
                env = env,
                name = name,
            ):
                config = _get_config(candidate_config, toolchain_config_specs)
        if not config:
            print(("%s not using checked in configs; Bazel version %s was " +
                   "picked/selected with '%s' compatible configs but none match " +
                   "the 'env = %s', 'config_repos = %s'," +
                   "and/or 'create_cc_configs = %s' passed as attrs") %
                  (
                      name,
                      bazel_version,
                      str(bazel_compat_configs),
                      env,
                      config_repos,
                      create_cc_configs,
                  ))
            return None, None

    # Resolve the digest:
    # First, try to use latest if that works.
    # If not, pick the first container that works.
    if (config and toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container != "" and
        config.name in container_to_config_spec_names_map[toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container]):
        digest = toolchain_config_suite_spec["toolchain_config_suite_autogen_spec"].latest_container
    if not digest:
        for key in container_to_config_spec_names_map.keys():
            if config and config.name in container_to_config_spec_names_map[key]:
                digest = key
                break
    if not digest:
        print(("%s not using checked in configs; no digest was found " +
               "for config '%s' in %s") % (name, config, container_to_config_spec_names_map))
        return None, None

    return config, digest

def _get_config(toolchain_config_spec_name, toolchain_config_specs):
    for spec in toolchain_config_specs:
        if spec.name == toolchain_config_spec_name:
            return spec
    return None

def _check_config(
        candidate_config,
        config_repos,
        create_cc_configs,
        env,
        name):
    if config_repos and config_repos != candidate_config.config_repos:
        return False
    if env and env != candidate_config.env:
        return False
    if create_cc_configs and not candidate_config.create_cc_configs:
        return False

    return True
