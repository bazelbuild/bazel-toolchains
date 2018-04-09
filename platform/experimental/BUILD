package(default_visibility = ["//visibility:public"])

# Constraints used in configuring the remote platforms and toolchains.
constraint_setting(name = "linux_distribution")

constraint_value(
    name = "jessie",
    constraint_setting = ":linux_distribution",
)

constraint_value(
    name = "trusty",
    constraint_setting = ":linux_distribution",
)

# RBE Debian8
platform(
    name = "rbe_debian8",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
        ":jessie",
    ],
    remote_execution_properties = """
          properties: {
            name: "container-image"
            value:"docker://gcr.io/cloud-marketplace/google/rbe-debian8@sha256:1ede2a929b44d629ec5abe86eee6d7ffea1d5a4d247489a8867d46cfde3e38bd"
         }
         """,
)


# Ubuntu GCC Fully-loaded
platform(
    name = "ubuntu_gcc_fully_loaded",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:gcc",
        ":trusty",
    ],
    remote_execution_properties = """
          properties: {
            name: "container-image"
            value:"docker://gcr.io/asci-toolchain/nosla-ubuntu-gcc-fl@sha256:20bf8513ba378ff3288904ab73b9993586c731e42855e27cf3be42c785a42489"
         }
         """,
)
