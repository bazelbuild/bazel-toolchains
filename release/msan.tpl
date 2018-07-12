
# Created on ${DATE}
# Container: ${CONTAINER_NAME}@${CONTAINER_SHA}
docker_toolchain_autoconfig(
    name = "msan-${DISTRO}-clang-${CONFIG_VERSION}-bazel_${BAZEL_VERSION}-autoconfig",
    additional_repos = ${DISTRO}_clang_default_repos(),
    base = "@${DISTRO}-clang//image",
    bazel_version = "${BAZEL_VERSION}",
    env = clang_env() + {
        "BAZEL_LINKOPTS": "-lc++:-lc++abi:-lm",
    },
    keys = ${DISTRO}_clang_default_keys(),
    packages = ${DISTRO}_clang_default_packages(),
    tags = ["manual"],
    test = True,
)
