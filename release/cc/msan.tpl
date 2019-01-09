
# This target is auto-generated from release/msan.tpl and should not be
# modified directly.
# Created on ${DATE}
# Container: ${NAME}@${SHA}
# Clang revision: ${CLANG_REVISION}
docker_toolchain_autoconfig(
    name = "msan-${DISTRO}-clang-${CONFIG_VERSION}-bazel_${BAZEL_VERSION}-autoconfig",
    additional_repos = ${DISTRO}_clang_default_repos(),
    base = "@${DISTRO}-clang//image",
    bazel_version = "${BAZEL_VERSION}",
    env = dicts.add(clang_env(), {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    }),
    keys = ${DISTRO}_clang_default_keys(),
    packages = ${DISTRO}_clang_default_packages(),
    tags = ["manual"],
    test = True,
)
