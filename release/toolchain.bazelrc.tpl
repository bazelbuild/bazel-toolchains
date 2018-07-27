# This file is auto-generated from release/toolchain.bazelrc.tpl and should not
# be modified directly.

# Toolchain related flags to append at the end of your .bazelrc file.
build:remote --host_javabase=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}:jdk8
build:remote --javabase=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}:jdk8
build:remote --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8
build:remote --java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8
build:remote --crosstool_top=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}/bazel_${BAZEL_VERSION}/default:toolchain
build:remote --action_env=BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1
# Platform flags:
# The toolchain container used for execution is defined in the target indicated
# by "extra_execution_platforms", "host_platform" and "platforms".
# If you are using your own toolchain container, you need to create a platform
# target with "constraint_values" that allow for the toolchain specified with
# "extra_toolchains" to be selected (given constraints defined in
# "exec_compatible_with").
# More about platforms: https://docs.bazel.build/versions/master/platforms.html
build:remote --extra_toolchains=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}/bazel_${BAZEL_VERSION}/cpp:cc-toolchain-clang-x86_64-default
build:remote --extra_execution_platforms=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}:${PLATFORM}
build:remote --host_platform=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}:${PLATFORM}
build:remote --platforms=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}:${PLATFORM}

# Experimental configs for sanitizers, use --config=remote,remote-xxsan,remote-<asan/tsan/msan> (in that order)
# See https://github.com/bazelbuild/bazel/issues/5291.
build:remote-xxsan --copt=-gmlt
build:remote-xxsan --strip=never

build:remote-asan --copt=-fsanitize=address
build:remote-asan --linkopt=-fsanitize=address

build:remote-tsan --copt=-fsanitize=thread
build:remote-tsan --linkopt=-fsanitize=thread

build:remote-msan --copt=-fsanitize=memory
build:remote-msan --linkopt=-fsanitize=memory
build:remote-msan --cxxopt=--stdlib=libc++
build:remote-msan --copt=-fsanitize-memory-track-origins
build:remote-msan --host_crosstool_top=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}/bazel_${BAZEL_VERSION}/default:toolchain
build:remote-msan --crosstool_top=@bazel_toolchains//${PACKAGE}/${CONFIG_VERSION}/bazel_${BAZEL_VERSION}/msan:toolchain
