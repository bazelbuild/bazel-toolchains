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
"""Rules to export a file/directory located inside a container available as a tarball."""

def _container_file_export_impl(ctx):
    """Implementation of the container_file_export rule."""
    input = ctx.file._container_file_export_exec
    args = [
        input.path,
        ctx.attr.image,
        ctx.attr.src_path,
        ctx.outputs.out.path,
    ]

    # The command may only access files declared in inputs.
    ctx.actions.run_shell(
        arguments = args,
        inputs = [input],
        outputs = [ctx.outputs.out],
        progress_message = "copying %{} out of docker image %{} ...".format(ctx.attr.src_path, ctx.attr.image),
        command = "$1 $2 $3 $4",
    )

_container_file_export = rule(
    implementation = _container_file_export_impl,
    attrs = {
        "image": attr.string(mandatory = True),
        "src_path": attr.string(mandatory = True),
        "_container_file_export_exec": attr.label(
            default = Label("//skylib:container_file_export.sh"),
            single_file = True,
            allow_files = True,
        ),
    },
    outputs = {
        "out": "%{name}.tar.gz",
    },
    executable = False,
)

# Rules to export a file/directory located inside a container available as a tarball.
# Example usage: exporting python3 interpreter as tarball from python-runtime image.
# Both `image` and `source` attrs are required.
#
#   container_file_export(
#     name = 'python3',
#     image = 'l.gcr.io/google/python:latest',
#     src_path = '/opt/python3.6'
#   )
def container_file_export(**kwargs):
    _container_file_export(**kwargs)
