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

def _add(dict,
         var_name,
         key,
         value,
         verifier_fcn=None,
         transform_fcn=None,
        ):
    """Add a key-value to a dict.
    
    If value is None, don't add anything.
    The dict will always be a string->string dict, but the value argument to this function may be of a different type.
    
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
        verifier_fcn(var_name, value) # verifier_fcn will fail() if necessary
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


def create_exec_properties_dict(
    # The asterisk means that all following arguments must be specified by name at the call site.
    # This allows future insertions of arguments to this function without breaking callers which might have otherwise depended on argument ordering.
    *,
    container_image=None,
    pool=None,
    os_family=None,
    gce_machine_type=None,
    jdk_version=None,
    docker_add_capabilities=None,
    docker_drop_capabilities=None,
    docker_network_enabled=None,
    docker_privileged=None,
    docker_run_as_root=None,
    docker_runtime=None,
    docker_sibling_containers=None,
    docker_ulimits=None,
    docker_use_urandom=None):
    """Return a dict with exec_properties that are supported by RBE.
    
    Args:
    container_image (string): The container that RBE will execute in.
    pool (string): If specified, the action will be executed only on this worker pool.
    os_family (string): If specified, the action will be executed only on workers of this OS family.
    gce_machine_type (string): If specified, the action will be executed only on workers of this machine type.
    jdk_version (string): If specified, the action will be executed only on workers that have this JDK version.
    docker_add_capabilities (string): If specified, RBE will add these (comma separated) capabilities to the capabilities it uses for running docker.
    docker_drop_capabilities (string): If specified, RBE will remove these (comma separated) capabilities from the capabilities it uses for running docker.
    docker_network_enabled (bool): If set to True, executions running in the docker container will have outgoing network access.
    docker_privileged (bool): If set to True, RBE will run docker in privileged mode.
    docker_run_as_root (bool): If set to True, RBE will run docker as root.
    docker_runtime (string): Used for GPU support. E.g. set to "nvidia".
    docker_sibling_containers (bool): If set to True, RBE will run docker in a way that allows it to spawn new docker containers.
    docker_ulimits (string): Adjusts the ulimit values send to docker.
    docker_use_urandom (bool): If set to True, RBE will mount dev/urandom as /dev/random inside the docker container.
    
    For more information about these options, see https://cloud.google.com/remote-build-execution/docs/remote-execution-environment#remote_execution_properties
    
    Returns: the dict
    """
    dict = {}
    _add(dict, "container_image", "container-image", container_image, _verify_string)
    _add(dict, "pool", "Pool", pool, _verify_string)
    _add(dict, "os_family", "OSFamily", os_family, _verify_os)
    _add(dict, "gce_machine_type", "gceMachineType", gce_machine_type, _verify_string)
    _add(dict, "jdk_version", "jdk-version", jdk_version, _verify_string)
    _add(dict, "docker_add_capabilities", "dockerAddCapabilities", docker_add_capabilities, _verify_string)
    _add(dict, "docker_drop_capabilities", "dockerDropCapabilities", docker_drop_capabilities, _verify_string)
    _add(dict, "docker_network_enabled", "dockerNetwork", docker_network_enabled, _verify_bool, _transform_network)
    _add(dict, "docker_privileged", "dockerPrivileged", docker_privileged, _verify_bool)
    _add(dict, "docker_run_as_root", "dockerRunAsRoot", docker_run_as_root, _verify_bool)
    _add(dict, "docker_runtime", "dockerRuntime", docker_runtime, _verify_string)
    _add(dict, "docker_sibling_containers", "dockerSiblingContainers", docker_sibling_containers, _verify_bool)
    _add(dict, "docker_ulimits", "dockerUlimits", docker_ulimits, _verify_string)
    _add(dict, "docker_use_urandom", "dockerUseURandom", docker_use_urandom, _verify_bool)
    return dict


def merge_dicts(*dict_args):
    """
    Merge any number of dicts into a new dict,
    precedence goes to key value pairs in latter dicts.
    """
    result = {}
    for dictionary in dict_args:
        result.update(dictionary)
    return result

