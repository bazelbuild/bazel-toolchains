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

"""This file contains macros to create and manipulate dictionaries of properties to be used as execution properties for RBE.
"""

def _add(
        dict,
        var_name,
        key,
        value,
        verifier_fcn = None,
        transform_fcn = None):
    """Add a key-value to a dict.

    If value is None, don't add anything.
    The dict will always be a string->string dict, but the value argument to this function may be of a different type.

    Args:
      dict: The dict to update.
      var_name: Used for error messages.
      key: The key in the dict.
      value: The value provided by the caller. This may or may not be what ends up in the dict.
      verifier_fcn: Verifies the validity of value. On error, it's the verifier's responsibility to call fail().
      transform_fcn: Transform the value provided to this function with a value to put in the dict.
          Note that a transform_fcn is not needed for casting a non string to string, this will be done anyway.
    """
    if value == None:
        return
    if verifier_fcn != None:
        verifier_fcn(var_name, value)  # verifier_fcn will fail() if necessary
    if transform_fcn != None:
        value = transform_fcn(value)
    dict[key] = str(value)

def _verify_string(var_name, value):
    if type(value) != "string":
        fail("%s must be a string" % var_name)

def _verify_bool(var_name, value):
    if type(value) != "bool":
        fail("%s must be a bool" % var_name)

def _verify_os(var_name, value):
    _verify_string(var_name, value)
    valid_os_list = ["Linux", "Windows"]
    if value not in valid_os_list:
        fail("%s must be one of %s" % (var_name, valid_os_list))

def _transform_network(value):
    return "standard" if value else "off"



def create_exec_properties_dict(**kwargs):
    """Return a dict with exec_properties that are supported by RBE.

    Args:
      **kwargs: Arguments specifying what keys are populated in the returned dict.
          Note that the name of the key in kwargs is not the same as the name of the key in the returned dict.
          For more information about what each parameter is see https://cloud.google.com/remote-build-execution/docs/remote-execution-environment#remote_execution_properties.
          If this link is broken for you, you may not to be whitelisted for RBE. See https://groups.google.com/forum/#!forum/rbe-alpha-customers.    

    Returns:
      A dict that can be used as, for example, the exec_properties parameter of platform.
    """
    params = {
        "container_image" : struct(
            key="container-image",
            verifier_fcn=_verify_string),
        "docker_add_capabilities" : struct(
            key="dockerAddCapabilities",
            verifier_fcn=_verify_string),
        "docker_drop_capabilities" : struct(
            key="dockerDropCapabilities",
            verifier_fcn=_verify_string),
        "docker_network_enabled" : struct(
            key="dockerNetwork",
            verifier_fcn=_verify_bool,
            transform_fcn=_transform_network),
        "docker_privileged" : struct(
            key="dockerPrivileged",
            verifier_fcn=_verify_bool),
        "docker_run_as_root" : struct(
            key="dockerRunAsRoot",
            verifier_fcn=_verify_bool),
        "docker_runtime" : struct(
            key="dockerRuntime",
            verifier_fcn=_verify_string),
        "docker_sibling_containers" : struct(
            key="dockerSiblingContainers",
            verifier_fcn=_verify_bool),
        "docker_ulimits" : struct(
            key="dockerUlimits",
            verifier_fcn=_verify_string),
        "docker_use_urandom" : struct(
            key="dockerUseURandom",
            verifier_fcn=_verify_bool),
        "gce_machine_type" : struct(
            key="gceMachineType",
            verifier_fcn=_verify_string),
        "jdk_version" : struct(
            key="jdk-version",
            verifier_fcn=_verify_string),
        "os_family" : struct(
            key="OSFamily",
            verifier_fcn=_verify_os),
        "pool" : struct(
            key="Pool",
            verifier_fcn=_verify_string),
    }

    dict = {}
    for var_name, value in kwargs.items():
        if not var_name in params:
            fail("%s is not a valid var_name" % var_name)
        p = params[var_name]
        _add(dict=dict,
             var_name=var_name,
             key=p.key,
             value=value,
             verifier_fcn=p.verifier_fcn if hasattr(p, "verifier_fcn") else None,
             transform_fcn=p.transform_fcn if hasattr(p, "transform_fcn") else None)
    return dict

def merge_dicts(*dict_args):
    """Merge any number of dicts into a new dict.

    Args:
      *dict_args: A list of zero or more dicts.

    Returns:
      A merge of the input dicts. Precedence goes to key value pairs in latter dicts.
    """
    result = {}
    for dictionary in dict_args:
        result.update(dictionary)
    return result
