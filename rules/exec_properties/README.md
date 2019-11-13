# exec_properties.bzl

exec_properties.bzl contains the following Starlark macros:
* rbe_exec_properties
* custom_exec_properties
* create_rbe_exec_properties_dict

## rbe_exec_properties

`rbe_exec_properties` is a Starlark macro that can be called from the
`WORKSPACE` file. It wraps a repo rule that creates a local repository. This
local repository contains a set of standard constants each of which contains a
dictionary of remote execution properties that are consumable by RBE.

A standrad name for this repository is `exec_properties`, and that's the name
that should generally be used.

## custom_exec_properties

`custom_exec_properties` is a Starlark macro that can be called from the
`WORKSPACE` file. It wraps a repo rule that creates a local repository. This
local repository contains a set of user defined constants, each of which
contains a dictionary of remote execution properties.

It is highly recommended to use a globally unique name for this repo rule (and
definitely not `exec_properties`) for reasons that are discussed in more details
[below](#anti-patterns).

## create_rbe_exec_properties_dict

`create_rbe_exec_properties_dict` is a Starlark macro that creates a dictionary
of remote execution properties. `create_rbe_exec_properties_dict` ensures that
the created dictionary is compatible with what RBE supports.

## Use cases

The following are some use cases showing how these repo rules should be used.

### Use case 1 - The standard use case:

In the `WORKSPACE` file, call
```
rbe_exec_properties(
    name = "exec_properties",
)
```

This creates a local repo `@exec_properties` with standard RBE execution
property constants. For example, `NETWORK_ON` which is the dict
`{"dockerNetwork" : "standard"}`. (For the full list of these constants see
`STANDARD_PROPERTY_SETS` in exec_properties.bzl.)

Then, in some `BUILD` file in your Bazel project, you can reference this
execution property constant as follows:
```
load("@exec_properties//:constants.bzl", "NETWORK_ON")
...
foo_test(
   ...
   exec_properties = NETWORK_ON,
)
```

### Use case 2 - local execution

If Bazel is set up so that the targets are executed locally, then the contents
of `exec_properties` are ignored.

### Use case 3 - non-RBE remote execution:

Let's assume that the non-RBE remote execution endpoint provides a macro similar
to `rbe_exec_properties` (say `other_re_exec_properties`), which populates the
same constants (e.g. `NETWORK_ON`) with possibly different dict values. In this
case, the `WORKSPACE` would, presumably, look like this:
```
other_re_exec_properties(
    name = "exec_properties",
)
```

And the targets in the `BUILD` files will be able to depend on targets from
other Bazel projects that were written with RBE in mind, as the name of the
repo defined in the `WORKSPACE` (`exec_properties` in this case) is the same.
That is why the repo name `exec_properties` does *not* contain the word RBE.

### Use case 4 - rbe_exec_properties with override_constants:

Let's now assume that a particular Bazel project, running with a particular RBE
setup, wants to run all its remote execution actions without network access,
possibly for the sake of identifying any network dependencies. This would be
achieved as follows.

In the `WORKSPACE` file, call
```
rbe_exec_properties(
    name = "exec_properties",
    override_constants = {
        "NETWORK_ON": create_rbe_exec_properties_dict(docker_network = "off"),
    },
)
```

This would override the meaning of `NETWORK_ON` for this Bazel project only.
For this override to work, we depend on targets marking their network dependecy
by using `NETWORK_ON` that was loaded from the repo `@exec_properties`.

### Use case 5 - custom execution properties

In this scenario, let's assume that a target is best run remotely on a high
memory GCE machine. Let's also assume that the RBE setup associated with the
Bazel project where the target is defined has workers of type `n1-highmem-8`.

Setting `exec_properties = {"gceMachineType" : "n1-highmem-8"}` is problematic
because it does not lend itself to another Bazel project depending on this
target in all cases. See [anti-patterns](#anti-patterns) below. Unlike the case
of `NETWORK_ON`, `rbe_exec_properties` does not provide a standard
`HIGH_MEM_MACHINE` execution property constant (although it might do so in the
future).

The recommended way for a Bazel project (let's call this project, project A) to
define this high-mem dependency is as follows:

In the `WORKSPACE` file, call:
```
custom_exec_properties(
    name = "proj_a_prefix_high_mem_machine_exec_property",
    constants = {
        "HIGH_MEM_MACHINE": create_rbe_exec_properties_dict(gce_machine_type = "n1-highmem-8"),
    },
)
```

And then in the `BUILD` file:
```
load("@proj_a_prefix_high_mem_machine_exec_property//:constants.bzl", "HIGH_MEM_MACHINE")
foo_library(
    name="my_lib",
    ...
    exec_properties = HIGH_MEM_MACHINE,
)
```

A depending Bazel project (project B) must also call `custom_exec_properties`
in its `WORKSPACE` and map `HIGH_MEM_MACHINE`. It may, for whatever reason,
decide to map it to something else.
```
custom_exec_properties(
    name = "proj_a_prefix_high_mem_machine_exec_property",
    constants = {
        "HIGH_MEM_MACHINE": ...,
    },
)
```

## Anti-patterns

As alluded to in the use cases described above, there are some anti-patterns to
avoid.

### Anti-pattern 1 - Do not populate the exec_properties dict manually.

⚠️ **Warning**: Avoid creating a dict that looks like this.
```
{
    "gceMachineType" : "n1-highmem-8",
    "dockerPrivileged" : "True",
    "dockerSiblingContainers" : "True",
}
```

Instead, always prefer using `create_rbe_exec_properties_dict` like so:
```
create_rbe_exec_properties_dict(
    gce_machine_type = "n1-highmem-8",
    docker_privileged = True,
    docker_sibling_containers = True,
)
```

`create_rbe_exec_properties_dict` is better because typos in key names will be
caught early, while parsing the Bazel code, instead of having RBE just ignore
keys that it doesn't recognize and having the developer spend more time that is
necessary trying to figure out what went wrong. Furthermore,
`create_rbe_exec_properties_dict` will perform some validation about the values.

### Anti-pattern 2 - Do not call create_rbe_exec_properties_dict from a target.

Instead `create_rbe_exec_properties_dict` should be called from the `WORKSPACE`
in the context of creating a local repo, typically using
`custom_exec_properties`. It can also be called from a `BUILD` file in the
context of defining a platform.

Here is what might go wrong if it is called directly when populating the
`exec_properties` field of a target.

Let's assume that Bazel project A defines a `foo_library` target that, if
executed remotely on RBE, should run on a high memory machine such as
`n1-highmem-8`. So the target looks like this:

⚠️ **Warning**: Do not do this!
```
foo_library(
   name="my_lib",
   ...
   exec_properties = create_rbe_exec_properties_dict(gce_machine_type = "n1-highmem-8"),
)
```

Now let's assume that Bazel project B has a target that transitively depeneds on
project A's target `:my_lib`. If the bazel invocation is configured to execute
remotely, it will only be able to execute `:my_lib` on a worker whose machine
type is `n1-highmem-8`.

This can be problematic for a few reasons. Perhaps for cost reasons, the owners
of project B do not maintain such machines and instead want to build this
`foo_library` on `n1-highmem-4` machines. Or perhaps, they are using a different
remote execution end point (not RBE) that defines a completely different way to
specify that an action runs remotely on a high memory machine. If this is the
case, project B will not be able to depend on project A's target `:my_lib`.

The proper way for project A to define this dependency on high memory machines
is descibed in use case 5 [above](#use-case-5---custom-execution-properties).

### Anti-pattern 3 - Do not create repo names that are not properly prefixed.

When creating local repos, other than `@exec_properties`, using
`rbe_exec_properties` and when creating any local repos using
`custom_exec_properties`, add a prefix to the repo name to make it globally
unique. This is important in order to avoid name clashes with other Bazel
projects.

Here is an example of what might go wrong.

Bazel project A's `WORKSPACE` contains the following snippet:

⚠️ **Warning**: Do not do this!
```
custom_exec_properties(
    name = "my_exec_properties",
    constants = {
        "MY_DOCKER_FLAGS": create_some_combination_of_exec_properties_docker_flags(),
    },
)
```
  
And project A defines in one of its `BUILD` files, a `foo_library` that uses
this constant `MY_DOCKER_FLAGS`.

Similarly Bazel project B's `WORKSPACE` contains a very similar snippet, which
uses the same local repo name and the same constant name as project A does, but
with a different content.

⚠️ **Warning**: Do not do this either!
```
custom_exec_properties(
    name = "my_exec_properties",
    constants = {
        "MY_DOCKER_FLAGS": create_some_other_combination_of_exec_properties_docker_flags(),
    },
)
```

The owners of projects A and B are unaware of each other, but Bazel project C,
has some targets that depend on project A and other targets that depend on
project B. That means that project C will have to define a local repo
`@my_exec_properties` which contains a constant `MY_DOCKER_FLAGS`. But it will
not be able to do so in a way that will not break at least one of its dependencies.

