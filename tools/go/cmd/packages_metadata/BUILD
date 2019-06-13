load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_default_library",
    srcs = ["packages_metadata.go"],
    importpath = "github.com/bazelbuild/bazel-toolchains/tools/go/cmd/packages_metadata",
    visibility = ["//visibility:private"],
    deps = [
        "@com_github_pkg_errors//:go_default_library",
        "@in_gopkg_yaml_v2//:go_default_library",
    ],
)

go_binary(
    name = "packages_metadata",
    embed = [":go_default_library"],
    visibility = ["//visibility:public"],
)
