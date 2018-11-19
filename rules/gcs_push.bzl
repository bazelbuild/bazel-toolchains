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

def _impl(ctx):
    """Implementation for the gcs_push rule.

    Args:
        ctx: The bazel rule context
    """

    target_file_name = ctx.attr.target_file_name or ctx.file.file.basename
    if ctx.attr.append_current_date:
        target_file_name += "_$(date +%Y%m%d)"

    bucket = ctx.attr.bucket
    if bucket.endswith("/"):
        bucket = bucket.rstrip("/")

    command = "gsutil cp {file} {bucket}/{target_file_name}".format(
        file = ctx.file.file.short_path,
        bucket = bucket,
        target_file_name = target_file_name,
    )

    ctx.actions.write(ctx.outputs.executable, command, is_executable = True)

    runfiles = ctx.runfiles(files = [ctx.file.file])
    return [DefaultInfo(runfiles = runfiles)]

_attrs = {
    "bucket": attr.string(
        mandatory = True,
    ),
    "file": attr.label(
        mandatory = True,
        allow_single_file = True,
    ),
    "target_file_name": attr.string(),
    "append_current_date": attr.bool(default = False),
}

gcs_push = rule(
    attrs = _attrs,
    implementation = _impl,
    executable = True,
)

"""Skylark rule for pushing a file to GCS bucket.
The rule uses gsutil tool installed in the system to upload a file to a GCS
bucket.
To install gsutil, please refer to:
  https://cloud.google.com/storage/docs/gsutil
You need to have write access to the GCS bucket.
Args:
  name: Name of the rule.
  bucket: The GCS bucket to upload the file to.
  file: The file which we are uploading.
  target_file_name: name of the file to created in the GCS bucket, default to
    the same name as the local file.
  append_current_date: if true, append a "_" then the current date in the format
    of YYYYMMDD to the name of uploaded file. Default to False.
"""
