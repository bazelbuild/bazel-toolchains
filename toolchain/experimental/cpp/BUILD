package(default_visibility = ["//visibility:public"])

toolchain(
    name = "cc-toolchain-clang-x86_64",
    exec_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//tools/cpp:clang",
    ],
    target_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
    ],
    toolchain = "//configs/debian8_clang/0.3.0/bazel_0.10.0:cc-compiler-k8",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
