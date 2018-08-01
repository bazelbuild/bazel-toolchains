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
def _impl(repository_ctx):
  """Core implementation of gsutil_cp."""
  target_file = repository_ctx.attr.target_file or repository_ctx.attr.file
  # Add a top-level BUILD file to export all the downloaded files.
  repository_ctx.file("BUILD", """
package(default_visibility = ["//visibility:public"])
exports_files(["{file}"])""".format(file=target_file))
  gsutil_cp_cmd = ["gsutil"]
  gsutil_cp_cmd += [
      "cp",
      "{gcs_bucket}/{file}".format(
          gcs_bucket=repository_ctx.attr.gcs_bucket,
          file=repository_ctx.attr.file
      ),
      target_file,
  ]
  gsutil_cp_result = repository_ctx.execute(gsutil_cp_cmd)
  if gsutil_cp_result.return_code:
    fail("gsutil cp command failed: %s (%s)" % (gsutil_cp_result.stderr, " ".join(gsutil_cp_cmd)))
  repository_ctx.file("validation.sh", """
#!/bin/bash
if [ $(sha256sum {file} | head -c 64) != {sha256} ]; then
  exit -1
else
  exit 0
fi""".format(file=target_file, sha256=repository_ctx.attr.sha256))
  validate_result = repository_ctx.execute(["bash", "validation.sh"])
  if validate_result.return_code:
    fail("SHA256 of downloaded file does not match given SHA256: %s" % validate_result.stderr)
  rm_result = repository_ctx.execute(["rm", "validation.sh"])
  if rm_result.return_code:
    fail("Failed to remove temporary file: %s" % rm_result.stderr)
gsutil_cp = repository_rule(
    attrs = {
        "gcs_bucket": attr.string(mandatory = True),
        "file": attr.string(mandatory = True),
        "target_file": attr.string(),
        "sha256": attr.string(mandatory = True),
    },
    implementation = _impl,
)
"""Downloads a file from GCS bucket using gsutil command.
The rule uses gsutil tool installed in the system to down a file from a GCS bucket,
and make it available for other rules to use (e.g. container_image rule).
To install gsutil, please refer to:
  https://cloud.google.com/storage/docs/gsutil
And you need to have the read access to the GCS bucket.
Args:
  name: name of the rule.
  gcs_bucket: the GCS bucket which contains the file.
  file: the file which we are downloading.
  target_file: (optional) the filename in the bazel workspace.
               Use the filename in the GCS if not specified.
  sha256: the sha256 of the file.
"""
