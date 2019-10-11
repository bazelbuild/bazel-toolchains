# exec_properties.bzl

exec_properties.bzl contains the following starlark macros:
* rbe_exec_properties
* custom_exec_properties
* create_exec_properties_dict
* merge_dicts

## rbe_exec_properties

rbe_exec_properties is a starlark macro that can be called from the WORKSPACE file. It wraps a repo
rule that creates a local repository. This local repository contains a set of standard constants
each of which contains a dictionary of remote execution properties that are consumable by RBE.

A standrad name for this repository is "exec_properties", and that's the name that should generally
be used.

## custom_exec_properties

custom_exec_properties is a starlark macro that can be called from the WORKSPACE file. It wraps a
repo rule that creates a local repository. This local repository contains a set of user defined
constants, each of which contains a dictionary of remote execution properties.

It is highly recommended to use a globally unique name for this repo (and definitely not
"exec_properties") for reasons that are discussed in more details [below](#anti-patterns).

## create_exec_properties_dict

create_exec_properties_dict is a starlark macro that creates a dictionary of remote execution
properties. create_exec_properties_dict ensures that the created dictionary is compatible with
what RBE supports.

It is highly recommended that this macro only be called from the WORKSPACE file in the context of
creating repo rules using rbe_exec_properties or custom_exec_properties. See more on this below.

## merge_dicts

merge_dicts is a starlark macro that merges dictionaries of remote execution properties.

## Use cases

The following are some use cases showing how these repo rules should be used.

### Use case 1 - The standard use case:

In the WORKSPACE file, call
```
  rbe_exec_properties(
      name = "exec_properties",
  )
```

This creates a local repo @rbe_exec_properties with standard RBE execution property constants. For
example, NETWORK_ON which is the dict {"dockerNetwork" : "standard"}. (For the full list of these
constants see STANDARD_PROPERTY_SETS in exec_properties.bzl.)

Then, in some BUILD file, you can reference this execution property constant as follows:

  load("@exec_properties//:constants.bzl", "NETWORK_ON")
  ...
  foo_test(
     ...
     exec_properties = NETWORK_ON,
  )

The reason not to directly set exec_properties = {...} in a target is that then it might be hard to
depend on such a target from another repo, if, say, that other repo wants to use remote execution
but not RBE.

### Use case 2 - local execution

If Bazel is set up so that the targets are executed locally, then the contents of exec_properties
are ignored.

### Use case 3 - non-RBE remote execution:

Let's assume that the non-RBE remote execution endpoint provides a macro similar to
rbe_exec_properties (say other_re_exec_properties), which populates the same constants (e.g.
NETWORK_ON) with possibly different dict values.
In this case, the WORKSPACE would look like this:
  other_re_exec_properties(
      name = "exec_properties",
  )

And the targets in the BUILD files will be able to depend on targets from other repos that were
written with RBE in mind, as the name of the repo defined in the WORKSPACE (exec_properties in this
case) is the same. That is why the repo name exec_properties does *not* contain the word RBE.

### Use case 4 - rbe_exec_properties with override_constants:

Let's now assume that a particular repo, running with a particular RBE setup, wants to run
everything without network access. This would be achieved as follows.

In the WORKSPACE file, call
  rbe_exec_properties(
      name = "exec_properties",
      override_constants = {
          "NETWORK_ON": create_exec_properties_dict(docker_network = "off"),
      },
  )

This would override the meaning of NETWORK_ON for this workspace only.
For this override to work, we depend on targets marking their network dependecy by using NETWORK_ON
that was loaded from the repo @exec_properties.

### Use case 5 - custom execution properties

In this scenario, let's assume that a target is best run remotely on a high memory GCE machine.
The RBE setup associated with the workspace where the target is defined has workers of type
"n1-highmem-8".
Setting exec_properties = {"gceMachineType" : "n1-highmem-8"} is problematic because it does not
lend itself to another repo depending on this target if, for example, the other repo uses a remote
execution endpoint other than RBE. Or, it might use RBE but have a different high memory GCE
machine such as "n1-highmem-16". Unlike the case of NETWORK_ON, rbe_exec_properties does not
provide a standard HIGH_MEM_MACHINE execution property set (although it might do so in the future).

The recommended way to define this high-mem dependency is as follows:

In the WORKSPACE file, call
  custom_exec_properties(
      name = "my_bespoke_exec_properties",
      constants = {
          "HIGH_MEM_MACHINE": create_exec_properties_dict(gce_machine_type = "n1-highmem-8"),
      },
  )

And then in the BUILD file:
  load("@my_bespoke_exec_properties//:constants.bzl", "HIGH_MEM_MACHINE")
  foo_bin(
      ...
      exec_properties = HIGH_MEM_MACHINE,
  )

A depending repo can then either define HIGH_MEM_MACHINE on @my_bespoke_exec_properties to be
{"gceMachineType" : "n1-highmem-8"}, or it can define it to be anything else, such as, for example
{"gceMachineType" : "n1-highmem-16"} or some other property name that is consumable by a non-RBE
remote execution endpoint.

## Anti-patterns

As alluded to in the use cases described above, there are some anti-patterns to avoid.

### Anti-pattern 1 - Do not create repo names that are not properly prefixed.

When creating local repos, other than @exec_properties, using rbe_exec_properties and when creating
any local repos using custom_exec_properties, add a prefix to the repo name to make it globally
unique. This is important in order to avoid name clashes with other repos.

Here is an example of what might go wrong.

Workspace A's WORKSPACE contains the following snippet:
  custom_exec_properties(
      name = "my_exec_properties",
      constants = {
          "MY_DOCKER_FLAGS": create_some_combination_of_exec_properties_docker_flags(),
      },
  )
  
And workspace A defines a foo_library that uses this constant MY_DOCKER_FLAGS.

Similarly workspace B's WORKSPACE contains a very similar snippet, which uses the same repo name
and same constant name as repo A does, but with a different content:
  custom_exec_properties(
      name = "my_exec_properties",
      constants = {
          "MY_DOCKER_FLAGS": create_some_other_combination_of_exec_properties_docker_flags(),
      },
  )

Now the owners of repos A and B are unaware of each other, but repo C, has some targets that depend
on repo A and other targets that depend on repo B. That means that repo C will have to define a
local repo @my_exec_properties which contains a constant MY_DOCKER_FLAGS. But it will not be able
to do so in a way that will not break at least one of its dependencies.
 
### Anti-pattern 2 - Do not call create_exec_properties_dict directly from BUILD files.

Instead create_exec_properties_dict should only be called from the WORKSPACE in the context of
creating a local repo, typically using custom_exec_properties.

Here is what might go wrong.

Let's assume that repo A defines a foo_library target that, if executed remotely on RBE, should run
on a high CPU machine such as "n1-highcpu-64". So the target looks like this:
  foo_library(
     name="my_lib",
     ...
     exec_properties = create_exec_properties_dict(gce_machine_type = "n1-highcpu-64"),
  )

Now let's assume that repo B has a target that transitively depeneds on repo A's target :my_lib.
If repo B's target runs on RBE, it will only be able to run on a worker whose machine type is
"n1-highcpu-64".

This can be problematic for a few reasons. Perhaps for cost reasons, the owners of repo B do not
maintain such machines and instead want to build this foo_library on "n1-highcpu-8" machines. Or
perhaps, they are using a different remote execution end point that defines a completely different
way to specify that an action runs remotely on a high-cpu machine. If this is the case, repo B will
not be able to depend on repo A's target :my_lib.

The proper way for repo A to define this dependency on high CPU machines is to add to their
WORKSPACE file:
  custom_exec_properties(
      name = "some_repo_specific_prefix_exec_properties",
      constants = {
          "HIGH_CPU_MACHINE": create_exec_properties_dict(gce_machine_type = "n1-highcpu-64"),
      },
  )
  
And in their BUILD file:
  load("@some_repo_specific_prefix_exec_properties//:constants.bzl", "HIGH_CPU_MACHINE")
  ...
  foo_library(
     name="my_lib",
     ...
     exec_properties = HIGH_CPU_MACHINE,
  )
  
repo A should also provide a deps() macro that should be called from any WORKSPACE that depends on
repo A. The deps macro will look something like:

def deps():
  ...
  excludes = native.existing_rules().keys()
  if "some_repo_specific_prefix_exec_properties" not in excludes:
      custom_exec_properties(
          name = "some_repo_specific_prefix_exec_properties",
          constants = {
              "HIGH_CPU_MACHINE": create_exec_properties_dict(gce_machine_type = "n1-highcpu-64"),
          },
      )
    
That way, a repo B, should have in its WORKSPACE:
  load("@repo_a:deps.bzl", repo_a_deps = "deps")
  repo_a_deps()

But it can also add, further up in its WORKSPACE, its own definition of
@some_repo_specific_prefix_exec_properties.


