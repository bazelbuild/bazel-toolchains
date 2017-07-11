package(default_visibility = ["//visibility:public"])

java_toolchain(
    name = "remote_toolchain",
    bootclasspath = ["@bazel_tools//tools/jdk:bootclasspath"],
    encoding = "UTF-8",
    extclasspath = ["@bazel_tools//tools/jdk:extclasspath"],
    forcibly_disable_header_compilation = 0,
    genclass = ["@bazel_tools//tools/jdk:genclass"],
    header_compiler = ["@bazel_tools//tools/jdk:turbine"],
    ijar = ["@bazel_tools//third_party/ijar:ijar"],
    javabuilder = ["@bazel_tools//tools/jdk:javabuilder"],
    javac = ["@bazel_tools//third_party/java/jdk/langtools:javac_jar"],
    javac_supports_workers = 1,
    jvm_opts = [
        "-XX:+TieredCompilation",
        "-XX:TieredStopAtLevel=1",
    ],
    misc = [
        "-XDskipDuplicateBridges=true",
    ],
    singlejar = ["@bazel_tools//src/tools/singlejar:singlejar"],
    source_version = "8",
    target_version = "8",
)
