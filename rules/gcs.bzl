# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Skylark rule for pulling a file from GCS bucket.
"""

_GCS_FILE_BUILD = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "file",
    srcs = ["{}"],
)
"""

def _gcs_file_impl(ctx):
  """Implementation of the gcs_file rule."""
  repo_root = ctx.path(".")
  forbidden_files = [
      repo_root,
      ctx.path("WORKSPACE"),
      ctx.path("BUILD"),
      ctx.path("BUILD.bazel"),
      ctx.path("file/BUILD"),
      ctx.path("file/BUILD.bazel"),]
  downloaded_file_path = ctx.attr.downloaded_file_path or ctx.attr.file
  download_path = ctx.path("file/" + downloaded_file_path)
  if download_path in forbidden_files or not str(download_path).startswith(str(repo_root)):
    fail("'%s' cannot be used as downloaded_file_path in gcs_file" % ctx.attr.downloaded_file_path)
  # Add a top-level BUILD file to export all the downloaded files.
  ctx.file("file/BUILD", _GCS_FILE_BUILD.format(downloaded_file_path))
  gsutil_cp_cmd = ["gsutil"]
  gsutil_cp_cmd += [
      "cp",
      "{bucket}/{file}".format(
          bucket=ctx.attr.bucket,
          file=ctx.attr.file
      ),
      download_path,
  ]
  gsutil_cp_result = ctx.execute(gsutil_cp_cmd)
  if gsutil_cp_result.return_code:
    fail("gsutil cp command failed: %s (%s)" % (gsutil_cp_result.stderr, " ".join(gsutil_cp_cmd)))
  ctx.file("validation.sh", """
#!/bin/bash
if [ $(sha256sum {file} | head -c 64) != {sha256} ]; then
  exit -1
else
  exit 0
fi""".format(file=download_path, sha256=ctx.attr.sha256))
  validate_result = ctx.execute(["bash", "validation.sh"])
  if validate_result.return_code:
    fail("SHA256 of downloaded file does not match given SHA256: %s" % validate_result.stderr)
  rm_result = ctx.execute(["rm", "validation.sh"])
  if rm_result.return_code:
    fail("Failed to remove temporary file: %s" % rm_result.stderr)

gcs_file = repository_rule(
    attrs = {
        "bucket": attr.string(mandatory = True),
        "file": attr.string(mandatory = True),
        "downloaded_file_path": attr.string(),
        "sha256": attr.string(mandatory = True),
    },
    implementation = _gcs_file_impl,
)
"""Downloads a file from GCS bucket.
The rule uses gsutil tool installed in the system to download a file from a GCS bucket,
and make it available for other rules to use (e.g. container_image rule).
To install gsutil, please refer to:
  https://cloud.google.com/storage/docs/gsutil
You need to have read access to the GCS bucket.
Args:
  name: Name of the rule.
  bucket: The GCS bucket which contains the file.
  file: The file which we are downloading.
  downloaded_file_path: Path assigned to the file downloaded.
  sha256: The expected SHA-256 of the file downloaded.
"""
