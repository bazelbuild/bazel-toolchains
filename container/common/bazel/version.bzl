BAZEL_VERSION_SHA256S = {
    "0.14.1": "7b14e4fc76bf85c4abf805833e99f560f124a3b96d56e0712c693e94e19d1376",
    "0.15.0": "7f6748b48a7ea6bdf00b0e1967909ce2181ebe6f377638aa454a7d09a0e3ea7b",
    "0.15.2": "13eae0f09565cf17fc1c9ce1053b9eac14c11e726a2215a79ebaf5bdbf435241",
    "0.16.1": "17ab70344645359fd4178002f367885e9019ae7507c9c1ade8220f3628383444",
}

# This is the map from supported Bazel versions to the Bazel version used to
# generate the published toolchain configs that the former should be used with.
# This is needed because, in most cases, patch updates in Bazel do not result in
# changes in toolchain configs, so we do not publish duplicated toolchain
# configs. So, for example, Bazel 0.15.2 should still use published toolchain
# configs generated with Bazel 0.15.0.
BAZEL_VERSION_TO_CONFIG_VERSION = {
    "0.14.1": "0.14.1",
    "0.15.0": "0.15.0",
    "0.15.2": "0.15.0",
    "0.16.1": "0.16.1",
}
