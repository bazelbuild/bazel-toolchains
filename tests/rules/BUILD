# Simply ensures the file supposed to be downloaded by the gce_file
# test rule was actually downloaded
sh_test(
    name = "gcs_file_test",
    srcs = [":file_existence_test.sh"],
    args = ["$(location @download_test_gcs_file//file:test.txt)"],
    data = ["@download_test_gcs_file//file:test.txt"],
)
