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

"""Definitions of language_tool_layer and toolchain_container rules."""


load(
    "@io_bazel_rules_docker//container:container.bzl",
    _container = "container",
)


def _language_tool_layer_impl(ctx):
  """Implementation for the language_tool_layer rule.

  Args:
    ctx: ctx as the same for container_image rule.
    https://github.com/bazelbuild/rules_docker#container_image

  TODO(ngiraldo): add validations to restrict use of any other attrs.
  """
  result = _container.image.implementation(ctx)
  return struct(runfiles = result.runfiles,
                files = result.files,
                container_parts = result.container_parts,
                base = ctx.attr.base,
                debs = ctx.files.debs,
                tars = ctx.files.tars,
                input_files = ctx.files.files,
                env = ctx.attr.env,
                symlinks = ctx.attr.symlinks)

language_tool_layer_ = rule(
    attrs = _container.image.attrs,
    executable = True,
    outputs = _container.image.outputs,
    implementation = _language_tool_layer_impl,
)

def language_tool_layer(**kwargs):
  """A thin wrapper around attrs in container_image rule.

  All attrs in language_tool_layer will be passed into
  toolchain_container rule.

  Experimental rule.
  """
  language_tool_layer_(**kwargs)


def _toolchain_container_impl(ctx):
  """Implementation for the toolchain_container rule.

  toolchain_container rule composes all attrs from itself and language_tool_layer(s),
  and generates container using container_image rule.

  Args:
    ctx: ctx as the same as for container_image + list of language_tool_layer(s)
    https://github.com/bazelbuild/rules_docker#container_image
  """
  debs = []
  tars = []
  files = []
  env = {}
  symlinks = {}
  # TODO(ngiraldo): we rewrite env and symlinks if there are conficts,
  # warn the user of conflicts or error out.
  for layer in ctx.attr.layers:
    debs.extend(layer.debs)
    tars.extend(layer.tars)
    files.extend(layer.input_files)
    env.update(layer.env)
    symlinks.update(layer.symlinks)
  debs.extend(ctx.attr.debs)
  tars.extend(ctx.attr.tars)
  env.update(ctx.attr.env)
  symlinks.update(ctx.attr.symlinks)
  debs = depset(debs).to_list()
  files = depset(files).to_list()
  return _container.image.implementation(ctx, symlinks=symlinks, env=env, debs=debs, tars=tars, files=files)

toolchain_container_ = rule(
    attrs = _container.image.attrs + {
        "layers": attr.label_list(),
    },
    executable = True,
    outputs = _container.image.outputs,
    implementation = _toolchain_container_impl,
)

def toolchain_container(**kwargs):
  """Composes multiple language_tool_layers into a single resulting image.

  Experimental rule.
  """
  toolchain_container_(**kwargs)
