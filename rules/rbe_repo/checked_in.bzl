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
        bazel_to_config_version_map,
        config_repos,
        container_to_config_version_map,
        create_cc_configs,
        create_java_configs,
        digest,
        env,
        java_home,
        rbe_repo,
        rbe_repo_configs,
        registry,
        repository,
        requested_config,
        tag,
        use_checked_in_confs):
    """Check if checked-in configs are available and should be used.

    If so, return the config version. Otherwise return None.

    Args:
      name: Name of the rule target.
      base_container_digest: SHA256 sum digest of the base image.
      # TODO: update this doc
      bazel_to_config_version_map: Set to point to def bazel_to_config_versions()
          defined in the versions.bzl file generated in the output_base defined
          in the rbe_repo.
      bazel_version: Version string of the Bazel release.
      bazel_rc_version: The RC version of the Bazel release if the given
          Bazel release is a RC.
      config_repos: list of additional external repos corresponding to
          configure like repo rules that need to be produced in addition to
          local_config_cc.
      # TODO: update this doc
      container_to_config_version_map: Optional. Only required when export_configs
          is set. Set to point to def container_to_config_versions()
          defined in the versions.bzl file generated in the output_base defined
          in the rbe_repo.
      create_cc_configs: Optional. Specifies whether to generate C/C++ configs.
          Defauls to True.
      create_java_configs: Optional. Specifies whether to generate java configs.
          Defauls to True.
      digest: The digest of the container in which the configs are goings to
          be used.
      env: The environment dict.
      java_home: Path to the Java home.
      registry: The registry where the toolchain container can be found.
      rbe_repo: Dict containing values to identify a toolchain
          container + GitHub repo where configs are stored. Must
          include keys:
              'repo_name': name of the Bazel external repo containing
                  configs
              'output_base': relative location of the output base in the
                  GitHub repo where configs are located)
              'container_repo': repo for the base toolchain container
              'container_registry': registry for the base toolchain container
              'latest_container': sha of the latest container
      rbe_repo_configs: Must point to a list containing structs,
          each struct represents a repo config with 'name' (str),
         'java_home'(str), 'create_java_configs' (bool), 'create_cc_configs' (bool),
         'config_repos' (string list) and 'env' (dict).
      repository: The path to the toolchain container on the registry.
      requested_config: the config_name of the config requested by the user.
      tag: The tag on the toolchain container.
      use_checked_in_confs: Whether to use checked in configs.

    Returns:
      None
    """
    if use_checked_in_confs == CHECKED_IN_CONFS_FALSE:
        print("%s not using checked in configs as user set attr to false " % name)
        return None, None
    if bazel_rc_version:
        print("%s not using checked in configs as hazel rc version was used " % name)
        return None, None

    if not base_container_digest:
        # If no base_container_digest was set we only use checked-in confs if
        # the registry and repo match the rbe_repo
        if registry and registry != rbe_repo["container_registry"]:
            print(("%s not using checked in configs; registry was set to '%s' " +
                   "and rbe_repo is configured for '%s'") % (name, registry, rbe_repo["container_registry"]))
            return None, None
        if repository and repository != rbe_repo["container_repo"]:
            print(("%s not using checked in configs; repository was set to '%s' " +
                   "and rbe_repo is configured for '%s'") % (name, repository, rbe_repo["container_repo"]))
            return None, None

    if not bazel_to_config_version_map.get(bazel_version):
        print(("%s not using checked in configs; Bazel version %s was picked/selected " +
               "but no checked in config was found in map %s") % (name, bazel_version, str(bazel_to_config_version_map)))
        return None, None

    # Find a config for the given version of bazel
    bazel_compat_configs = bazel_to_config_version_map.get(bazel_version)
    if not bazel_to_config_version_map.get(bazel_version):
        print(("%s not using checked in configs; Bazel version %s was picked/selected " +
               "but no checked in config was found in map %s") % (name, bazel_version, str(bazel_to_config_version_map)))
        return None, None

    # Try to resolve the digest with the base_container_digest or if latest was set as tag
    if base_container_digest:
        digest = base_container_digest
    if tag:  # Implies `digest` is not specified.
        if tag == "latest" and rbe_repo.get("latest_container"):
            digest = rbe_repo["latest_container"]
            # if any tag other than latest is used we will not use checked-in configs
            # (to not hardcode tag info anywhere in these rules)

        else:
            print("%s not using checked in configs; tag (other than latest) was selected" % name)
            return None, None
    config = None

    # If a digest was provided/selected lets try to find a config that will work
    if digest:
        config = container_to_config_version_map.get(digest)
        if not config:
            print(("%s not using checked in configs; digest %s was picked/selected " +
                   "but no checked in config was found in map %s") % (name, digest, str(container_to_config_version_map)))
            return None, None
        if requested_config and config != requested_config:
            print(("%s not using checked in configs; config with name %s was requested " +
                   "but %s was found for the container with digest %s") % (name, requested_config, config, digest))
            return None, None

    # If a config was requested or found via digest, lets see if its compatible with
    # the selected Bazel version
    if requested_config or config:
        if not config:
            config = requested_config
        if config not in bazel_compat_configs:
            print(("%s not using checked in configs; config %s was picked/selected, Bazel version %s was picked/selected " +
                   "but no checked in config was found in %s") % (name, config, bazel_version, str(bazel_compat_configs)))
            return None, None

    # We have found a canidadate config, lets check if env / config_repos match
    if config and not _check_config(
        candidate_config_name = config,
        config_repos = config_repos,
        create_java_configs = create_java_configs,
        create_cc_configs = create_cc_configs,
        env = env,
        java_home = java_home,
        name = name,
        rbe_repo_configs = rbe_repo_configs,
    ):
        print(("%s not using checked in configs; '%s' was picked/selected " +
               "as a candidate matching config but it does not match " +
               "the 'env = %s', 'config_repos = %s', 'create_java_configs " +
               "= %s', and/or 'create_cc_configs = %s' passed as attrs") %
              (name, bazel_version, str(bazel_compat_configs), env, config_repos, create_java_configs, create_cc_configs))
        return None, None

    # If we have not found a config so far, pick one that will work for the
    # selected Bazel version
    if not config:
        for candidate_config in bazel_compat_configs:
            if _check_config(
                candidate_config_name = candidate_config,
                config_repos = config_repos,
                create_java_configs = create_java_configs,
                create_cc_configs = create_cc_configs,
                env = env,
                java_home = java_home,
                name = name,
                rbe_repo_configs = rbe_repo_configs,
            ):
                config = candidate_config
        if not config:
            print(("%s not using checked in configs; Bazel version %s was " +
                   "picked/selected with '%s' compatible configs but none match " +
                   "the 'env = %s', 'config_repos = %s', 'create_java_configs " +
                   "= %s', and/or 'create_cc_configs = %s' passed as attrs") %
                  (name, bazel_version, str(bazel_compat_configs), env, config_repos, create_java_configs, create_cc_configs))
            return None, None

        # Resolve the digest, for now:
        # Try to use latest if that works.
        # If not, pick the first container that works.
        if (config and rbe_repo.get("latest_container") and
            container_to_config_version_map[rbe_repo["latest_container"]] == config):
            digest = rbe_repo["latest_container"]
        if not digest:
            for key in container_to_config_version_map.keys():
                if container_to_config_version_map[key] == config:
                    digest = key
                    break
    if not digest:
        print(("%s not using checked in configs; no digest was found " +
               "for config %s in %s") % (name, config, container_to_config_version_map))
        return None, None

    print("%s is using checked-in configs %s" % (name, config))
    return config, digest

def _check_config(
        candidate_config_name,
        config_repos,
        create_java_configs,
        create_cc_configs,
        env,
        java_home,
        name,
        rbe_repo_configs):
    candidate_config = None
    for repo_conf in rbe_repo_configs:
        if repo_conf.name == candidate_config_name:
            candidate_config = repo_conf
    if not candidate_config:
        # This is a hard failure as it means the versions.bzl file or rbe_autoconfig rule is
        # not properly set up.
        fail("%s failed. Config %s was selected but is not present in %s" % (name, config, str(rbe_repo_configs)))
    if config_repos and config_repos != candidate_config.config_repos:
        return False
    if env and env != candidate_config.env:
        return False
    if create_java_configs and not candidate_config.create_java_configs:
        return False
    if create_java_configs and candidate_config.create_java_configs and java_home and java_home != candidate_config.java_home:
        return False
    if create_cc_configs and not candidate_config.create_cc_configs:
        return False

    return True
