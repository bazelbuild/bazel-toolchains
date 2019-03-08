""" Helpers to parse and check version of bazel."""

def extract_version_number(bazel_version_fallback):
    """Extracts the semantic version number from a version string

    Args:
      bazel_version_fallback: The bazel version to fall back to if the version
                              of Bazel running this function can't be
                              determined.

    Returns:
      The semantic version string, like "1.2.3".
    """
    bazel_version = _check_bazel_version(bazel_version_fallback)
    for i in range(len(bazel_version)):
        c = bazel_version[i]
        if not (c.isdigit() or c == "."):
            return bazel_version[:i]
    return bazel_version

def parse_rc(bazel_version):
    """Parse the version string of the given Bazel RC version

    Args:
        bazel_version: The Bazel version string.

    Returns:
        The integer RC number if the given bazel version was a RC version.
    """
    if bazel_version.find("rc") != -1:
        rc = ""
        for i in range(len(bazel_version) - bazel_version.find("rc") - 2):
            c = bazel_version[i + bazel_version.find("rc") + 2]
            if not c.isdigit():
                if rc == "":
                    return -1
                break
            rc += c
        return int(rc)

def _check_bazel_version(bazel_version_fallback):
    if "bazel_version" not in dir(native):
        fail("\nCurrent Bazel version is lower than 0.2.1 and is not supported with rbe_autoconfig.")
    elif not native.bazel_version:
        print(("\nCurrent running Bazel is not a release version and one " +
               "was not defined explicitly in rbe_autoconfig target. " +
               "Falling back to '%s'") % bazel_version_fallback)
        return bazel_version_fallback
    return native.bazel_version
