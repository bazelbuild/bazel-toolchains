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

load("@exec_properties//:constants.bzl", "NETWORK_ON")

# OVERRIDDEN_NETWORK_ON is actually the same as NETWORK_OFF (see WORKSPACE file).
load("@exec_properties_with_override//:constants.bzl", OVERRIDDEN_NETWORK_ON = "NETWORK_ON")

# BESPOKE_NETWORK_ON is the same as NETWORK_ON (see WORKSPACE file).
load("@network_on_exec_properties//:constants.bzl", "BESPOKE_NETWORK_ON")

# Test the docker_privileged property

constraint_setting(name = "constraint_privileged")

constraint_value(
    name = "constraint_privileged_on",
    constraint_setting = ":constraint_privileged",
)

platform(
    name = "platform_privileged_on",
    constraint_values = [":constraint_privileged_on"],
    parents = ["@rbe_default_with_docker_priveleged//config:platform"],
)

# privileged_off_test should run with @rbe_default_exec_properties//config:platform
sh_test(
    name = "privileged_off_test",
    srcs = ["privileged_off.sh"],
)

# privileged_on_test should run with :platform_privileged_on
sh_test(
    name = "privileged_on_test",
    srcs = ["privileged_on.sh"],
    exec_compatible_with = [
        ":constraint_privileged_on",
    ],
)

# Test the docker_network property

# Define constraint and platform for the NETWORK_ON execution property set.
constraint_setting(name = "constraint_network")

constraint_value(
    name = "constraint_network_enabled",
    constraint_setting = ":constraint_network",
)

platform(
    name = "platform_network_enabled",
    constraint_values = [":constraint_network_enabled"],
    exec_properties = NETWORK_ON,
    parents = ["@rbe_default_exec_properties//config:platform"],
)

# Define constraint and platform for the BESPOKE_NETWORK_ON execution property set, which should be
# identical to NETWORK_ON,
constraint_setting(name = "constraint_bespoke_network")

constraint_value(
    name = "constraint_bespoke_network_enabled",
    constraint_setting = ":constraint_bespoke_network",
)

platform(
    name = "platform_bespoke_network_enabled",
    constraint_values = [":constraint_bespoke_network_enabled"],
    exec_properties = BESPOKE_NETWORK_ON,
    parents = ["@rbe_default_exec_properties//config:platform"],
)

# Define constraint and platform for the OVERRIDDEN_NETWORK_ON execution property set, which is
# actually identical to NETWORK_OFF,
constraint_setting(name = "constraint_overridden_network")

constraint_value(
    name = "constraint_overridden_network_enabled",
    constraint_setting = ":constraint_overridden_network",
)

platform(
    name = "platform_overridden_network_enabled",
    constraint_values = [":constraint_overridden_network_enabled"],
    exec_properties = OVERRIDDEN_NETWORK_ON,
    parents = ["@rbe_default_exec_properties//config:platform"],
)

# network_disabled_test should run with @rbe_default_exec_properties//config:platform
sh_test(
    name = "network_disabled_test",
    srcs = ["network_disabled.sh"],
)

# network_enabled_test should run with :platform_network_enabled
sh_test(
    name = "network_enabled_test",
    srcs = ["network_enabled.sh"],
    exec_compatible_with = [
        ":constraint_network_enabled",
    ],
)

# bespoke_network_enabled_test should run with :platform_bespoke_network_enabled
sh_test(
    name = "bespoke_network_enabled_test",
    srcs = ["network_enabled.sh"],
    exec_compatible_with = [
        ":constraint_bespoke_network_enabled",
    ],
)

# overridden_network_enabled_test should run with :platform_overridden_network_enabled
sh_test(
    name = "overridden_network_enabled_test",
    # :platform_overridden_network_enabled actually has the network disabled, not enabled.
    srcs = ["network_disabled.sh"],
    exec_compatible_with = [
        ":constraint_overridden_network_enabled",
    ],
)
