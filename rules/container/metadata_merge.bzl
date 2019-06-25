# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
metadata_merge accepts a list of YAML metadata generated by the download_pkgs
& packages_metadata rules. metadata_metaga merges the input list into a single
YAML file. The tags are added in order & de-duplicated. The de-duplication
removes later occurences of the same tag. The packages are merged in order
including any duplicates.

Example for the following input YAML files:
File 1 (generated by security_check rule):
tags:
- foo

File 2 (generated by download_pkgs rule):
packages:
- name: foo
  version: 1

File 3 (generated by security_check rule):
tags:
- bar

File 4 (generated by download_pkgs rule)
packages:
- name: baz
  version: 2

The merged YAML will be as follows:
tags:
- foo
- bar
packages:
- name: foo
  version: 1
- name: baz
  version: 2
"""

def _impl(ctx):
    yaml_files = ctx.files.srcs
    if len(yaml_files) == 0:
        fail("Attribute yamls to {} did not specify any YAML files.".format(ctx.label))
    args = []
    for yaml_file in yaml_files:
        args.append("-yamlFile")
        args.append(yaml_file.path)
    args.append("-outFile")
    args.append(ctx.outputs.yaml.path)
    ctx.actions.run(
        inputs = yaml_files,
        outputs = [ctx.outputs.yaml],
        executable = ctx.executable._merger,
        arguments = args,
        mnemonic = "MetadataYAMLMerge",
    )

metadata_merge = rule(
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".yaml"],
            doc = "YAML file targets to merge.",
        ),
        "_merger": attr.label(
            default = "@bazel_toolchains//src/go/cmd/metadata_merge",
            cfg = "host",
            executable = True,
            doc = "The go binary that merges a given list of YAML files to " +
                  "produce a single output YAML.",
        ),
    },
    outputs = {
        "yaml": "%{name}.yaml",
    },
    implementation = _impl,
)
