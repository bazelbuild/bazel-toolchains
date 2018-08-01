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

load("@io_bazel_rules_docker//container:container.bzl", _container = "container")
load("@base_images_docker//package_managers:download_pkgs.bzl", _download = "download")
load("@base_images_docker//package_managers:install_pkgs.bzl", _install = "install")
load("@base_images_docker//package_managers:apt_key.bzl", _key = "key")

debian_pkgs_attrs = _container.image.attrs + _key.attrs + _download.attrs + {
    # Redeclare following attributes as non-mandatory.
    "image_tar": attr.label(
        allow_files = True,
        single_file = True,
    ),
    "image": attr.label(
        allow_files = True,
        single_file = True,
    ),
    "packages": attr.string_list(),
    "keys": attr.label_list(
        allow_files = True,
    ),
    "output_image_name": attr.string(),
}

def _aggregate_debian_packages_impl(ctx):
    """Implementation for the aggregate_debian_packages rule.
    aggregate_debian_packages rule composes all attrs from itself and language_tool_layer(s),
    and generates a tarball of debian packages using download_pkgs rule.
    Args:
      ctx: ctx for list of language_tool_layer(s)
    """

    tars = []
    files = []
    env = {}
    symlinks = {}
    packages = []
    additional_repos = []
    keys = []
    installables_tars = []

    for layer in ctx.attr.language_layers:
        tars.extend(layer.tars)
        files.extend(layer.input_files)
        env.update(layer.env)
        symlinks.update(layer.symlinks)
        packages.extend(layer.packages)
        additional_repos.extend(layer.additional_repos)
        keys.extend(layer.keys)
        if layer.installables_tar:
            installables_tars.append(layer.installables_tar)
    tars.extend(ctx.files.tars)
    env.update(ctx.attr.env)
    symlinks.update(ctx.attr.symlinks)
    packages.extend(ctx.attr.packages)
    additional_repos.extend(ctx.attr.additional_repos)
    keys.extend(ctx.files.keys)

    files = depset(files).to_list()
    packages = depset(packages).to_list()
    additional_repos = depset(additional_repos).to_list()
    keys = depset(keys).to_list()
    installables_tars = depset(installables_tars).to_list()

    download_base = ctx.files.base[0]

    # Create an intermediate image with additional gpg keys used to download packages.
    if keys != []:
        image_with_keys = "%s_with_keys" % ctx.attr.name

        # Declare intermediate output file generated by add_apt_key rule.
        image_with_keys_output_executable = ctx.actions.declare_file(image_with_keys)
        image_with_keys_output_tarball = ctx.actions.declare_file(image_with_keys + ".tar")
        image_with_keys_output_layer = ctx.actions.declare_file(image_with_keys + "-layer.tar")

        _key.implementation(
            ctx,
            name = image_with_keys,
            image_tar = ctx.files.base[0],
            keys = keys,
            output_executable = image_with_keys_output_executable,
            output_tarball = image_with_keys_output_tarball,
            output_layer = image_with_keys_output_layer,
        )
        download_base = image_with_keys_output_tarball

    result = _download.implementation(
        ctx,
        image_tar = download_base,
        packages = packages,
        additional_repos = additional_repos,
    )

    return [DefaultInfo(runfiles = result.runfiles)]


aggregate_debian_packages = rule(
    attrs = debian_pkgs_attrs + {
        "language_layers": attr.label_list(),
    },
    executable = True,
    outputs = _download.outputs,
    implementation = _aggregate_debian_packages_impl,
)
