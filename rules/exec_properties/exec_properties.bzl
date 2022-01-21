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

"""This file contains macros that create repository rules for standard and custom sets of execution properties.

It also contains macros to create and manipulate dictionaries of properties to be used as execution 
properties for RBE.

"""

def _add(
        dict,
        var_name,
        key,
        value,
        verifier_fcn = None):
    """Add a key-value to a dict.

    If value is None, don't add anything.
    The dict will always be a string->string dict, but the value argument to this function may be of a different type.

    Args:
      dict: The dict to update.
      var_name: Used for error messages.
      key: The key in the dict.
      value: The value provided by the caller. This may or may not be what ends up in the dict.
      verifier_fcn: Verifies the validity of value. On error, it's the verifier's responsibility to call fail().
    """
    if value == None:
        return
    if verifier_fcn != None:
        verifier_fcn(var_name, value)  # verifier_fcn will fail() if necessary
    dict[key] = str(value)

def _add_labels(
        dict,
        var_name,
        labels):
    """Add zero of more label key-values to a dict.

    If labels is None, don't add anything. Otherwise, labels must be a string->string dictionary.
    For every key, value in the labels dictionary, add to dict the key-value ("label:" + key -> value).

    Args:
      dict: The dict to update.
      var_name: Used for error messages.
      labels: A string->string dictionary of labels.
    """
    if labels == None:
        return
    _verify_labels(var_name, labels)
    for key, value in labels.items():
        dict["label:%s" % key] = value

def _verify_string(var_name, value):
    if type(value) != "string":
        fail("%s must be a string" % var_name)

def _verify_bool(var_name, value):
    if type(value) != "bool":
        fail("%s must be a bool" % var_name)

def _verify_labels(var_name, labels):
    # labels must be a string->string dict.
    if type(labels) != "dict":
        fail("%s must be a dict" % var_name)
    for key, value in labels.items():
        _verify_label(var_name, key, value)

def _verify_label(var_name, key, value):
    # This is based on the Requirements for labels outlined in
    # https://cloud.google.com/resource-manager/docs/creating-managing-labels.

    # Keys have a minimum length of 1 character and a maximum length of 63
    # characters, and cannot be empty. Values can be empty, and have a maximum
    # length of 63 characters.
    _verify_string("%s.%s" % (var_name, key), key)
    if len(key) == 0:
        fail("%s cannot contain an empty key" % var_name)
    if len(key) > 63:
        fail("%s.%s exceeds the 63 character length limit for a label name" % (var_name, key))
    _verify_string("value of %s.%s" % (var_name, key), value)
    if len(value) > 63:
        fail("value of %s.%s exceeds the 63 character length limit for a label value" % (var_name, key))

    # The actual requirement is:
    # Keys and values can contain only lowercase letters, numeric characters,
    # underscores, and dashes. All characters must use UTF-8 encoding, and
    # international characters are allowed.
    # Keys must start with a lowercase letter or international character.
    #
    # But since I don't know of a way to verify international characters in
    # starlark, we will enforce slightly less strict requirements. Namely:
    # Keys and labels must not contain upper case letters.
    # Keys must not start with a number, underscore or dash.
    if key != key.lower():
        fail("%s.%s must not contain capital letters" % (var_name, key))
    if value != value.lower():
        fail("value of %s.%s must not contain capital letters" % (var_name, key))
    if "0123456789-_".find(key[0]) != -1:
        fail("%s.%s must start with a lowercase letter or international character" % (var_name, key))

def _verify_one_of(var_name, value, valid_values):
    _verify_string(var_name, value)
    if value not in valid_values:
        fail("%s must be one of %s" % (var_name, valid_values))

def _verify_os(var_name, value):
    _verify_one_of(var_name, value, ["Linux", "Windows"])

def _verify_docker_network(var_name, value):
    _verify_one_of(var_name, value, ["standard", "off"])

def _verify_docker_shm_size(var_name, value):
    _verify_string(var_name, value)

    # The expect format is <number><unit>.
    # <number> must be greater than 0.
    # <unit> is optional and can be b (bytes), k (kilobytes), m (megabytes), or g (gigabytes).
    # The entire string is also allowed to be empty.
    if value == "":
        return  # Both <number> and <unit> can be unspecified.

    # The last char can be one of [bkmg], or it can be omitted. The rest should be a number.
    # Peel off the last character if it is a valid unit and put the remainder in number.
    number = value if "bkmg".find(value[-1:]) == -1 else value[:-1]
    if not number.isdigit():
        fail("%s = \"%s\" must be of the format \"[0-9]*[bkmg]?\"" % (var_name, value))
    if number == "0":
        fail("%s = \"%s\" must have a numeric value greater than 0." % (var_name, value))

PARAMS = {
    "container_image": struct(
        key = "container-image",
        verifier_fcn = _verify_string,
    ),
    "docker_add_capabilities": struct(
        key = "dockerAddCapabilities",
        verifier_fcn = _verify_string,
    ),
    "docker_drop_capabilities": struct(
        key = "dockerDropCapabilities",
        verifier_fcn = _verify_string,
    ),
    "docker_network": struct(
        key = "dockerNetwork",
        verifier_fcn = _verify_docker_network,
    ),
    "docker_privileged": struct(
        key = "dockerPrivileged",
        verifier_fcn = _verify_bool,
    ),
    "docker_run_as_root": struct(
        key = "dockerRunAsRoot",
        verifier_fcn = _verify_bool,
    ),
    "docker_runtime": struct(
        key = "dockerRuntime",
        verifier_fcn = _verify_string,
    ),
    "docker_shm_size": struct(
        key = "dockerShmSize",
        verifier_fcn = _verify_docker_shm_size,
    ),
    "docker_sibling_containers": struct(
        key = "dockerSiblingContainers",
        verifier_fcn = _verify_bool,
    ),
    "docker_ulimits": struct(
        key = "dockerUlimits",
        verifier_fcn = _verify_string,
    ),
    "docker_use_urandom": struct(
        key = "dockerUseURandom",
        verifier_fcn = _verify_bool,
    ),
    "gce_machine_type": struct(
        key = "gceMachineType",
        verifier_fcn = _verify_string,
    ),
    "os_family": struct(
        key = "OSFamily",
        verifier_fcn = _verify_os,
    ),
    "pool": struct(
        key = "Pool",
        verifier_fcn = _verify_string,
    ),
}

def create_exec_properties_dict(**kwargs):
    fail("create_exec_properties_dict is deprecated. Please use create_rbe_exec_properties_dict instead.")

def create_rbe_exec_properties_dict(**kwargs):
    """Return a dict with exec_properties that are supported by RBE.

    Args:
      **kwargs: Arguments specifying what keys are populated in the returned dict.
          Note that the name of the key in kwargs is not the same as the name of the key in the returned dict.
          For more information about what each parameter is see https://cloud.google.com/remote-build-execution/docs/remote-execution-properties.
          If this link is broken for you, you may not to be whitelisted for RBE. See https://groups.google.com/forum/#!forum/rbe-alpha-customers.

    Returns:
      A dict that can be used as, for example, the exec_properties parameter of platform.
    """
    dict = {}
    for var_name, value in kwargs.items():
        if var_name in PARAMS:
            p = PARAMS[var_name]
            _add(
                dict = dict,
                var_name = var_name,
                key = p.key,
                value = value,
                verifier_fcn = p.verifier_fcn if hasattr(p, "verifier_fcn") else None,
            )
        elif var_name == "labels":
            # labels is a special parameter. Its value is a dict and it maps to
            # multiple properties.
            _add_labels(
                dict = dict,
                var_name = var_name,
                labels = value,
            )
        else:
            fail("%s is not a valid var_name" % var_name)

    return dict

def merge_dicts(*dict_args):
    fail("merge_dicts is deprecated. Please use dicts.add() instead. See https://github.com/bazelbuild/bazel-skylib/blob/master/docs/dicts_doc.md")

def _exec_property_sets_repository_impl(repository_ctx):
    repository_ctx.file(
        "BUILD",
        content = """
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
package(default_visibility = ["//visibility:public"])
bzl_library(
    name = "constants",
    srcs = [
        "constants.bzl",
    ],
)
""",
        executable = False,
    )
    repository_ctx.file(
        "constants.bzl",
        content = repository_ctx.attr.constants_bzl_content,
        executable = False,
    )

# _exec_property_sets_repository is a repository rule that creates a repo with the specified exec_property_sets.
_exec_property_sets_repository = repository_rule(
    implementation = _exec_property_sets_repository_impl,
    local = True,
    attrs = {
        "constants_bzl_content": attr.string(
            mandatory = True,
            doc = "The content of the constants.bzl file within the repository rule.",
        ),
    },
)

def _verify_dict_of_dicts(name, dicts):
    """ Verify that dict is of type {string->{string->string}}.

    Args:
      name: Name of the repo rule. Used for error messages.
      dicts: a dict whose key is a string and whose value is a dict from string to string.
    """

    # Verify that dict is of type {string->{string->string}}.
    for key, value in dicts.items():
        if type(key) != "string":
            fail("In repo rule %s, execution property set name %s must be a string" % (name, key))
        if type(value) != "dict":
            fail("In repo rule %s, execution property set of %s must be a dict" % (name, key))
        for k, v in value.items():
            if type(k) != "string":
                fail("In repo rule %s, execution property set %s, the key %s must be a string" % (name, key, k))
            if type(v) != "string":
                fail("In repo rule %s, execution property set %s, key %s, the value %s must be a string" % (name, key, k, v))

def custom_exec_properties(name, constants):
    """ Creates a repository containing execution property dicts.

    Use this macro in your WORKSPACE.

    Args:
      name: Name of the repo rule.
      constants: A dictionary whose key is the constant name and whose value is a string->string
          execution properies dict.
    """
    _verify_dict_of_dicts(name, constants)

    constants_bzl_content = ""
    for key, value in constants.items():
        constants_bzl_content += "%s = %s\n" % (key, value)

    _exec_property_sets_repository(
        name = name,
        constants_bzl_content = constants_bzl_content,
    )

# STANDARD_PROPERTY_SETS is the SoT for the list of constants that rbe_exec_properties defines.
# For more information about what each parameter of create_rbe_exec_properties_dict() means, see
# https://cloud.google.com/remote-build-execution/docs/remote-execution-properties.
STANDARD_PROPERTY_SETS = {
    "NETWORK_ON": create_rbe_exec_properties_dict(docker_network = "standard"),
    "NETWORK_OFF": create_rbe_exec_properties_dict(docker_network = "off"),
    "DOCKER_PRIVILEGED": create_rbe_exec_properties_dict(docker_privileged = True),
    "NOT_DOCKER_PRIVILEGED": create_rbe_exec_properties_dict(docker_privileged = False),
    "DOCKER_RUN_AS_ROOT": create_rbe_exec_properties_dict(docker_run_as_root = True),
    "NOT_DOCKER_RUN_AS_ROOT": create_rbe_exec_properties_dict(docker_run_as_root = False),
    "DOCKER_SIBLINGS_CONTAINERS": create_rbe_exec_properties_dict(docker_sibling_containers = True),
    "NOT_DOCKER_SIBLINGS_CONTAINERS": create_rbe_exec_properties_dict(docker_sibling_containers = False),
    "DOCKER_USE_URANDOM": create_rbe_exec_properties_dict(docker_use_urandom = True),
    "NOT_DOCKER_USE_URANDOM": create_rbe_exec_properties_dict(docker_use_urandom = False),
    "LINUX": create_rbe_exec_properties_dict(os_family = "Linux"),
    "WINDOWS": create_rbe_exec_properties_dict(os_family = "Windows"),
}

def rbe_exec_properties(name, override_constants = None):
    """ Creates a repository with several default execution property dictionaries.

    Use this macro in your WORKSPACE.

    Args:
      name: Name of repo rule.
      override_constants: An optional dict of exec_properties dicts. The keys of the
          override_constants dicts must be names of existing execution properties constants. The
          values are exec_properties dicts.
    """
    if override_constants == None:
        custom_exec_properties(name, STANDARD_PROPERTY_SETS)
        return

    _verify_dict_of_dicts(name, override_constants)
    dicts = {}
    for key, value in STANDARD_PROPERTY_SETS.items():
        dicts[key] = value
    for key, value in override_constants.items():
        if not key in dicts:
            fail("In repo rule %s, execution property set %s is not a standard property set name and hence cannot be overridden" % (name, key))
        dicts[key] = value

    custom_exec_properties(name, dicts)
