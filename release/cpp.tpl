# This target is auto-generated from release/cpp.tpl and should not be
# modified directly.
toolchain(
    name = "cc-toolchain-clang-x86_64-${TYPE}",
    exec_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//tools/cpp:clang",
        ${EXTRA_CONSTRAINTS}
    ],
    target_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
    ],
    toolchain = "//${PACKAGE}/${CONFIG_VERSION}/bazel_${BAZEL_VERSION}/${TYPE}:cc-compiler-k8",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
