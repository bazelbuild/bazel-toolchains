# Generated file, do not modify by hand
# Generated by rbe_custom rbe_autoconfig rule
""""Definitions to be used in rbe_repo attr of an rbe_autoconf rule. """

def configs():
    return []

DEFAULT_CONFIG = ""

# Returns a dict with suppported Bazel versions mapped to the config version to use.
def bazel_to_config_versions():
    return {
    }

# sha256 digest of the latest version of the toolchain container.
LATEST = ""

# Map from sha256 of the toolchain container to corresponding major container
# versions.
def container_to_config_versions():
    return {
    }

def versions():
    return struct(
        latest_container = LATEST,
        default_config = DEFAULT_CONFIG,
        rbe_repo_configs = configs,
        bazel_to_config_version_map = bazel_to_config_versions,
        container_to_config_version_map = container_to_config_versions,
    )
