load("//rules/experimental/rbe:exec_properties.bzl", "create_exec_properties_dict")
load("//configs/ubuntu16_04_clang:versions.bzl", "LATEST")

# Test the docker_privileged property
constraint_setting(name = "constraint_privileged")

constraint_value(
    name = "constraint_privileged_on",
    constraint_setting = ":constraint_privileged",
)

platform(
    name = "platform_privileged_on",
    constraint_values = [":constraint_privileged_on"],
    exec_properties = create_exec_properties_dict(
        container_image = "docker://marketplace.gcr.io/google/rbe-ubuntu16-04@%s" % LATEST,
        docker_privileged = True,
    ),
)

# privileged_off_test should run with @rbe_default//config:platform
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

# Test the docker_network_enabled property
constraint_setting(name = "constraint_network")

constraint_value(
    name = "constraint_network_enabled",
    constraint_setting = ":constraint_network",
)

platform(
    name = "platform_network_enabled",
    constraint_values = [":constraint_network_enabled"],
    exec_properties = create_exec_properties_dict(
        container_image = "docker://marketplace.gcr.io/google/rbe-ubuntu16-04@%s" % LATEST,
        docker_network_enabled = True,
    ),
)

# network_disabled_test should run with @rbe_default//config:platform
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
