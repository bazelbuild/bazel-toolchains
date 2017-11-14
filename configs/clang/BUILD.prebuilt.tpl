# This is the entry point for --crosstool_top.
#
# The cc_toolchain rule used is found by:
#
# 1. Finding the appropriate toolchain in the CROSSTOOL file based on the --cpu
#    and --compiler command line flags (if they exist, otherwise using the
#    "default_target_cpu" / "default_toolchain" fields in the CROSSTOOL file)
# 2. Concatenating the "target_cpu" and "compiler" fields of the toolchain in
#    use and using that as a key in the map in the "toolchains" attribute

filegroup(
    name = "empty",
    srcs = [],
)

cc_toolchain_suite(
    name = "toolchain",
    toolchains = {
        "k8|clang": ":cc-compiler-linux_x86_64",
    },
    proto = """
major_version: "local"
minor_version: ""
default_target_cpu: ""

default_toolchain {
  cpu: "k8"
  toolchain_identifier: "clang_linux_k8"
}

toolchain {
  abi_version: "clang_5.0"
  abi_libc_version: "%{libc_abi_version}"
  builtin_sysroot: ""
  compiler: "clang"
  host_system_name: "local"
  needsPic: true
  supports_gold_linker: false
  supports_incremental_linker: false
  supports_fission: false
  supports_interface_shared_objects: false
  supports_normalizing_ar: true
  supports_start_end_lib: false
  supports_thin_archives: true
  target_libc: "%{libc_name}"
  target_cpu: "k8"
  target_system_name: "local"
  toolchain_identifier: "clang_linux_k8"

  tool_path { name: "ar" path: "bin/llvm-ar" }
  tool_path { name: "compat-ld" path: "bin/ld.lld" }
  tool_path { name: "cpp" path: "bin/clang++" }
  tool_path { name: "dwp" path: "bin/llvm-dwp" }
  tool_path { name: "gcc" path: "bin/clang" }
  cxx_flag: "-std=c++17"
  # For some strange reason, ld.ldd does not work as a linker
  linker_flag: "-fuse-ld=lld"
  linker_flag: "external/%{workspace_name}/lib/libc++.a"
  linker_flag: "external/%{workspace_name}/lib/libc++abi.a"
  linker_flag: "-Bexternal/%{workspace_name}/bin/"

  # TODO(bazel-team): In theory, the path here ought to exactly match the path
  # used by clang for glibc. That works because bazel currently doesn't track files at
  # absolute locations and has no remote execution, yet. However, this will need
  # to be fixed, maybe with auto-detection?
%{libc_include_block}
  tool_path { name: "gcov" path: "/usr/bin/gcov" }

  # C(++) compiles invoke the compiler (as that is the one knowing where
  # to find libraries), but we provide LD so other rules can invoke the linker.
  tool_path { name: "ld" path: "bin/ld.lld" }

  tool_path { name: "nm" path: "bin/llvm-nm" }
  tool_path { name: "objcopy" path: "/usr/bin/objcopy" }
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  tool_path { name: "objdump" path: "bin/llvm-objdump" }
  tool_path { name: "strip" path: "/usr/bin/strip" }

  # We use libc++
  #unfiltered_cxx_flag: "-nostdinc"
  unfiltered_cxx_flag: "-nostdinc++"

  # Anticipated future default.
  unfiltered_cxx_flag: "-no-canonical-prefixes"

  # Use libc++
  unfiltered_cxx_flag: "-isystem"
  unfiltered_cxx_flag: "external/%{workspace_name}/include/c++/v1"
  # Following special header include needs to be after libc++ include, no
  # matter what the include_next docs say.
  unfiltered_cxx_flag: "-isystem"
  unfiltered_cxx_flag: "external/%{workspace_name}/lib/clang/5.0.0/include"

  # Make C++ compilation deterministic. Use linkstamping instead of these
  # compiler symbols.
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: '-D__DATE__=\"redacted\"'
  unfiltered_cxx_flag: '-D__TIMESTAMP__=\"redacted\"'
  unfiltered_cxx_flag: '-D__TIME__=\"redacted\"'

  # Security hardening on by default.
  # Conservative choice; -D_FORTIFY_SOURCE=2 may be unsafe in some cases.
  # We need to undef it before redefining it as some distributions now have
  # it enabled by default.
  compiler_flag: "-U_FORTIFY_SOURCE"
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  linker_flag: "-Wl,-z,relro,-z,now"

  # Enable coloring even if there's no attached terminal. Bazel removes the
  # escape sequences if --nocolor is specified. This isn't supported by gcc
  # on Ubuntu 14.04.
  compiler_flag: "-fcolor-diagnostics"

  # All warnings are enabled. Maybe enable -Werror as well?
  compiler_flag: "-Wall"

  # Keep stack frames for debugging, even in opt mode.
  compiler_flag: "-fno-omit-frame-pointer"

  # Anticipated future default.
  linker_flag: "-no-canonical-prefixes"
  # Gold linker only? Can we enable this by default?
  # linker_flag: "-Wl,--warn-execstack"
  # linker_flag: "-Wl,--detect-odr-violations"

  compilation_mode_flags {
    mode: DBG
    # Enable debug symbols.
    compiler_flag: "-g"
  }
  compilation_mode_flags {
    mode: OPT

    # No debug symbols.
    # Maybe we should enable https://gcc.gnu.org/wiki/DebugFission for opt or
    # even generally? However, that can't happen here, as it requires special
    # handling in Bazel.
    compiler_flag: "-g0"

    # Conservative choice for -O
    # -O3 can increase binary size and even slow down the resulting binaries.
    # Profile first and / or use FDO if you need better performance than this.
    compiler_flag: "-O2"

    # Disable assertions
    compiler_flag: "-DNDEBUG"

    # Removal of unused code and data at link time (can this increase binary size in some cases?).
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
    linker_flag: "-Wl,--gc-sections"
  }
  linking_mode_flags { mode: DYNAMIC }
}
""",
)

filegroup(
    name = "all_files",
    srcs = [
        ":compiler_files",
        ":libc++",
        ":linker_files",
        ":objcopy",
        ":strip",
    ],
)

filegroup(
    name = "compiler_files",
    srcs = [
        "bin/clang",
        "bin/clang-5.0",
        "bin/clang++",
        "bin/clang-apply-replacements",
        "bin/clang-change-namespace",
        "bin/clang-check",
        "bin/clang-cl",
        "bin/clang-cpp",
        "bin/clangd",
        "bin/clang-format",
        "bin/clang-import-test",
        "bin/clang-include-fixer",
        "bin/clang-offload-bundler",
        "bin/clang-query",
        "bin/clang-rename",
        "bin/clang-reorder-fields",
        "bin/clang-tidy",
        ":libc++_include",
    ],
)

filegroup(
    name = "libc++",
    srcs = [
        ":libc++_include",
        ":libc++_lib",
    ],
)

filegroup(
    name = "libc++_include",
    srcs = glob([
        "include/c++/v1/experimental/*",
        "include/c++/v1/ext/*",
        "include/c++/v1/*",
        "lib/clang/5.0.0/include/cuda_wrappers/*",
        "lib/clang/5.0.0/include/sanitizer/*",
        "lib/clang/5.0.0/include/xray/*",
        "lib/clang/5.0.0/include/*",
    ]),
)

filegroup(
    name = "libc++_lib",
    srcs = glob([
        "lib/*",
    ]),
)

filegroup(
    name = "linker_files",
    srcs = [
        "bin/clang",
        "bin/ld.lld",
        "bin/lld",
        "bin/lld-link",
        ":libc++_lib",
    ],
)

filegroup(
    name = "objcopy",
    srcs = [
    ],
)

filegroup(
    name = "strip",
    srcs = [
    ],
)

cc_toolchain(
  name = "cc-compiler-linux_x86_64",
  all_files = ":all_files",
  compiler_files = ":compiler_files",
  cpu = "k8",
  dwp_files = ":empty",
  dynamic_runtime_libs = [":empty"],
  linker_files = ":linker_files",
  objcopy_files = ":objcopy",
  static_runtime_libs = [':empty'],
  strip_files = ":strip",
  supports_param_files = 1,
  visibility = ["//visibility:public"],
)