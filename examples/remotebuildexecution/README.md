This directory contains some basic sample projects demonstrating how to
configure bazel to use the Remote Build Execution service. A given sample can be
executed by running:

bazel --bazelrc=bazelrc/latest.bazelrc test //examples/remotebuildexecution/\<target\> --config=remote --remote_instance_name=projects/\<your_project\>

Note that projects outside this repository will need to import this repository
using a WORKSPACE rule, as decribed at
https://releases.bazel.build/bazel-toolchains.html
