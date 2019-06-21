load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_default_library",
    srcs = ["metadata_merge.go"],
    importpath = "github.com/bazelbuild/bazel-toolchains/src/go/cmd/metadata_merge",
    visibility = ["//visibility:private"],
    deps = [
        "//src/go/pkg/metadata:go_default_library",
        "@in_gopkg_yaml_v2//:go_default_library",
    ],
)

go_binary(
    name = "metadata_merge",
    embed = [":go_default_library"],
    visibility = ["//visibility:public"],
)
