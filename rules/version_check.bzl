""" Helpers to parse and check version of bazel."""

def extract_version_number(bazel_version_fallback):
    """Extracts the semantic version number from a version string

    Args:
      bazel_version: the version string that begins with the semantic version
        e.g. "1.2.3rc1 abc1234" where "abc1234" is a commit hash.

    Returns:
      The semantic version string, like "1.2.3".
    """
    bazel_version = _check_bazel_version(bazel_version_fallback):
    for i in range(len(bazel_version)):
        c = bazel_version[i]
        if not (c.isdigit() or c == "."):
            return bazel_version[:i]
    return bazel_version

def parse_rc(bazel_version):
    if bazel_version.find("rc"):
        rc = ""
        for i in range(len(bazel_version) - bazel_version.find("rc")):
            c = bazel_version[i]
            if not c.isdigit():
                if rc == "":
                    return -1
                return int(rc)
            rc += c

def _check_bazel_version(bazel_version_fallback):
    if "bazel_version" not in dir(native):
        fail("\nCurrent Bazel version is lower than 0.2.1 and is not supported with rbe_autoconfig.")
    elif not native.bazel_version:
        print("\nCurrent running Bazel is not a release version and one " +
             " was not defined explicitly in rbe_autoconfig target.")
        return bazel_version_fallback
    return native.bazel_version
