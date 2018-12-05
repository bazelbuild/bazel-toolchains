load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "file_test",
)

# Simply ensures the file supposed to be downloaded by the gce_file
# test rule was actually downloaded and the contents of the file was
# "0"
file_test(
    name = "gcs_file_test",
    content = "0",
    file = "@download_test_gcs_file//file:test.txt",
)
