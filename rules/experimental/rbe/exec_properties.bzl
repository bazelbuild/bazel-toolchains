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

It also contains macros that create repository rules for standard and custom sets of execution
properties.

Here are some examples of how to use these repository rules:

Scenario 1 - The standard use case:

In the WORKSPACE file, call
  rbe_exec_properties(
      name = "exec_properties",
  )

This creates a local repo @rbe_exec_properties with standard RBE execution property constants. For
example, NETWORK_ON which is the dict {"dockerNetwork" : "standard"}

Then, in some BUILD file, you can reference this execution property constant as follows:

  load("@exec_properties//:constants.bzl", "NETWORK_ON")
  ...
  exec_properties = NETWORK_ON

The reason not to directly set exec_properties = {...} in a target is that then it might be hard to
depend on such a target from another repo, if, say, that other repo wants to use remote execution
but not RBE.

Scenario 2 - local execution

If bazel is set up so that the targets are executed locally, then the contents of exec_properties
are ignored.

Scenario 3 - non-RBE remote execution:

Let's assume that the non-RBE remote execution endpoint provides a macro similar to
rbe_exec_properties (say other_re_exec_properties), which populates the same constants (e.g.
NETWORK_ON) with possibly different dict values.
In this case, the WORKSPACE would look like this:
  other_re_exec_properties(
      name = "exec_properties",
  )

And the targets in the BUILD files will be able to depend on targets from other repos that were
written with RBE in mind.

Scenario 4 - rbe_exec_properties with override:

Let's now assume that a particular repo, running with a particular RBE setups, wants to run
everything without network access. This would be achieved as follows.

In the WORKSPACE file, call
  rbe_exec_properties(
      name = "exec_properties",
      override = {
          "NETWORK_ON": create_exec_properties_dict(docker_network = "off"),
      },
  )

This would override the meaning of NETWORK_ON for this workspace only.

Scenario 5 - custom execution properties

In this scenario, let's assume that a target is best run remotely on a high memory GCE machine.
The RBE setup associated with the workspace where the target is defined has workers of type
"n1-highmem-8".
Setting exec_properties = {"gceMachineType" : "n1-highmem-8"} is problematic because it does not
lend itself to another repo depending on this target if, for example, the other repo does not use
RBE. Or it might use RBE but have a different high memory GCE machine such as "n1-highmem-16".
Unlike the case of NETWORK_ON, rbe_exec_properties does not provide a standard HIGH_MEM_MACHINE
execution property set (although it might do so in the future).

The recommended way to do this is as follows:

In the WORKSPACE file, call
  custom_exec_properties(
      name = "my_bespoke_exec_properties",
      dicts = {
          "HIGH_MEM_MACHINE": create_exec_properties_dict(gce_machine_type = "n1-highmem-8"),
      },
  )

And then in the BUILD file:
  load("@my_bespoke_exec_properties//:constants.bzl", "HIGH_MEM_MACHINE")
  target(
      ...
      exec_properties = HIGH_MEM_MACHINE,
  )

A depending repo can then either define HIGH_MEM_MACHINE on @my_bespoke_exec_properties to be
{"gceMachineType" : "n1-highmem-8"}, or it can define it to be anything else.

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

def _verify_string(var_name, value):
    if type(value) != "string":
        fail("%s must be a string" % var_name)

def _verify_bool(var_name, value):
    if type(value) != "bool":
        fail("%s must be a bool" % var_name)

def _verify_one_of(var_name, value, valid_values):
    _verify_string(var_name, value)
    if value not in valid_values:
        fail("%s must be one of %s" % (var_name, valid_values))

def _verify_os(var_name, value):
    _verify_one_of(var_name, value, ["Linux", "Windows"])

def _verify_docker_network(var_name, value):
    _verify_one_of(var_name, value, ["standard", "off"])

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
    "jdk_version": struct(
        key = "jdk-version",
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
    """Return a dict with exec_properties that are supported by RBE.

    Args:
      **kwargs: Arguments specifying what keys are populated in the returned dict.
          Note that the name of the key in kwargs is not the same as the name of the key in the returned dict.
          For more information about what each parameter is see https://cloud.google.com/remote-build-execution/docs/remote-execution-environment#remote_execution_properties.
          If this link is broken for you, you may not to be whitelisted for RBE. See https://groups.google.com/forum/#!forum/rbe-alpha-customers.

    Returns:
      A dict that can be used as, for example, the exec_properties parameter of platform.
    """
    dict = {}
    for var_name, value in kwargs.items():
        if not var_name in PARAMS:
            fail("%s is not a valid var_name" % var_name)
        p = PARAMS[var_name]
        _add(
            dict = dict,
            var_name = var_name,
            key = p.key,
            value = value,
            verifier_fcn = p.verifier_fcn if hasattr(p, "verifier_fcn") else None,
        )
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

def _exec_property_sets_repository_impl(repository_ctx):
    repository_ctx.file(
        "BUILD",
        content = "",
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

def custom_exec_properties(name, dicts):
    """ Creates a repository containing execution property dicts.

    Use this macro in your WORKSPACE.

    Args:
      name: Name of the repo rule.
      dicts: The execution property set constants.
    """
    _verify_dict_of_dicts(name, dicts)

    constants_bzl_content = ""
    for key, value in dicts.items():
        constants_bzl_content += "%s = %s\n" % (key, value)

    _exec_property_sets_repository(
        name = name,
        constants_bzl_content = constants_bzl_content,
    )

STANDARD_PROPERTY_SETS = {
    "NETWORK_ON": create_exec_properties_dict(docker_network = "standard"),
    "NETWORK_OFF": create_exec_properties_dict(docker_network = "off"),
    "DOCKER_PRIVILEGED": create_exec_properties_dict(docker_privileged = True),
    "NOT_DOCKER_PRIVILEGED": create_exec_properties_dict(docker_privileged = False),
    "DOCKER_RUN_AS_ROOT": create_exec_properties_dict(docker_run_as_root = True),
    "NOT_DOCKER_RUN_AS_ROOT": create_exec_properties_dict(docker_run_as_root = False),
    "DOCKER_SIBLINGS_CONTAINERS": create_exec_properties_dict(docker_sibling_containers = True),
    "NOT_DOCKER_SIBLINGS_CONTAINERS": create_exec_properties_dict(docker_sibling_containers = False),
    "DOCKER_USE_URANDOM": create_exec_properties_dict(docker_use_urandom = True),
    "NOT_DOCKER_USE_URANDOM": create_exec_properties_dict(docker_use_urandom = False),
    "LINUX": create_exec_properties_dict(os_family = "Linux"),
    "WINDOWS": create_exec_properties_dict(os_family = "Windows"),
}

def rbe_exec_properties(name, override = None):
    """ Creates a repository with several default execution property dictionaries.

    Use this macro in your WORKSPACE.

    Args:
      name: Name of repo rule.
      override: An optional dict of exec_properties dicts. The keys of the override dicts must be
          names of existing execution properties constant. The values are exec_properties dicts.
    """
    if override == None:
        custom_exec_properties(name, STANDARD_PROPERTY_SETS)
        return

    _verify_dict_of_dicts(name, override)
    dicts = {}
    for key, value in STANDARD_PROPERTY_SETS.items():
        dicts[key] = value
    for key, value in override.items():
        if not key in dicts:
            fail("In repo rule %s, execution property set %s is not a standard property set name and hence cannot be overridden" % (name, key))
        dicts[key] = value

    custom_exec_properties(name, dicts)
