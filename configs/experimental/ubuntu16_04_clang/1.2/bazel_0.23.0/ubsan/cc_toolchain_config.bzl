# Copyright 2019 The Bazel Authors. All rights reserved.
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

"""A Starlark cc_toolchain configuration rule"""

load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
    "tool_path",
    "variable_with_value",
    "with_feature_set",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

def _impl(ctx):
    toolchain_identifier = "linux_gnu_x86"

    host_system_name = "i686-unknown-linux-gnu"

    target_system_name = "x86_64-unknown-linux-gnu"

    target_cpu = "k8"

    target_libc = "glibc_2.19"

    compiler = "clang"

    abi_version = "clang"

    abi_libc_version = "glibc_2.19"

    cc_target_os = None

    builtin_sysroot = None

    all_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
        ACTION_NAMES.lto_backend,
    ]

    all_cpp_compile_actions = [
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.clif_match,
    ]

    preprocessor_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.clif_match,
    ]

    codegen_compile_actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.lto_backend,
    ]

    all_link_actions = [
        ACTION_NAMES.cpp_link_executable,
        ACTION_NAMES.cpp_link_dynamic_library,
        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ]

    cpp_link_dynamic_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_dynamic_library,
        implies = [
            "symbol_counts",
            "strip_debug_symbols",
            "shared_flag",
            "linkstamps",
            "output_execpath_flags",
            "runtime_library_search_directories",
            "library_search_directories",
            "libraries_to_link",
            "user_link_flags",
            "linker_param_file",
            "fission_support",
            "sysroot",
        ],
        tools = [tool(path = "/usr/local/bin/clang++")],
    )

    cpp_link_executable_action = action_config(
        action_name = ACTION_NAMES.cpp_link_executable,
        implies = [
            "symbol_counts",
            "strip_debug_symbols",
            "linkstamps",
            "output_execpath_flags",
            "runtime_library_search_directories",
            "library_search_directories",
            "libraries_to_link",
            "force_pic_flags",
            "user_link_flags",
            "linker_param_file",
            "fission_support",
            "sysroot",
        ],
        tools = [tool(path = "/usr/local/bin/clang++")],
    )

    cpp_link_nodeps_dynamic_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_nodeps_dynamic_library,
        implies = [
            "symbol_counts",
            "strip_debug_symbols",
            "shared_flag",
            "linkstamps",
            "output_execpath_flags",
            "runtime_library_search_directories",
            "library_search_directories",
            "libraries_to_link",
            "user_link_flags",
            "linker_param_file",
            "fission_support",
            "sysroot",
        ],
        tools = [tool(path = "/usr/local/bin/clang++")],
    )

    cpp_link_static_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_static_library,
        implies = ["archiver_flags", "linker_param_file"],
        tools = [tool(path = "/usr/bin/ar")],
    )

    assemble_action = action_config(
        action_name = ACTION_NAMES.assemble,
        implies = [
            "user_compile_flags",
            "sysroot",
            "unfiltered_compile_flags",
            "compiler_input_flags",
            "compiler_output_flags",
        ],
        tools = [tool(path = "/usr/local/bin/clang")],
    )

    c_compile_action = action_config(
        action_name = ACTION_NAMES.c_compile,
        implies = [
            "user_compile_flags",
            "sysroot",
            "unfiltered_compile_flags",
            "compiler_input_flags",
            "compiler_output_flags",
        ],
        tools = [tool(path = "/usr/local/bin/clang")],
    )

    cpp_compile_action = action_config(
        action_name = ACTION_NAMES.cpp_compile,
        implies = [
            "user_compile_flags",
            "sysroot",
            "unfiltered_compile_flags",
            "compiler_input_flags",
            "compiler_output_flags",
        ],
        tools = [tool(path = "/usr/local/bin/clang")],
    )

    cpp_header_parsing_action = action_config(
        action_name = ACTION_NAMES.cpp_header_parsing,
        implies = [
            "user_compile_flags",
            "sysroot",
            "unfiltered_compile_flags",
            "compiler_input_flags",
            "compiler_output_flags",
        ],
        tools = [tool(path = "/usr/local/bin/clang")],
    )

    cpp_module_codegen_action = action_config(
        action_name = ACTION_NAMES.cpp_module_codegen,
        implies = [
            "user_compile_flags",
            "sysroot",
            "unfiltered_compile_flags",
            "compiler_input_flags",
            "compiler_output_flags",
        ],
        tools = [tool(path = "/usr/local/bin/clang")],
    )

    preprocess_assemble_action = action_config(
        action_name = ACTION_NAMES.preprocess_assemble,
        implies = [
            "user_compile_flags",
            "sysroot",
            "unfiltered_compile_flags",
            "compiler_input_flags",
            "compiler_output_flags",
        ],
        tools = [tool(path = "/usr/local/bin/clang")],
    )

    linkstamp_compile_action = action_config(
        action_name = ACTION_NAMES.linkstamp_compile,
        implies = [
            "user_compile_flags",
            "sysroot",
            "unfiltered_compile_flags",
            "compiler_input_flags",
            "compiler_output_flags",
        ],
        tools = [tool(path = "/usr/local/bin/clang")],
    )

    cpp_module_compile_action = action_config(
        action_name = ACTION_NAMES.cpp_module_compile,
        implies = [
            "user_compile_flags",
            "sysroot",
            "unfiltered_compile_flags",
            "compiler_input_flags",
            "compiler_output_flags",
        ],
        tools = [tool(path = "/usr/local/bin/clang")],
    )

    strip_action = action_config(
        action_name = ACTION_NAMES.strip,
        flag_sets = [
            flag_set(
                flag_groups = [
                    flag_group(flags = ["-S", "-p", "-o", "%{output_file}"]),
                    flag_group(
                        flags = [
                            "-R",
                            ".gnu.switches.text.quote_paths",
                            "-R",
                            ".gnu.switches.text.bracket_paths",
                            "-R",
                            ".gnu.switches.text.system_paths",
                            "-R",
                            ".gnu.switches.text.cpp_defines",
                            "-R",
                            ".gnu.switches.text.cpp_includes",
                            "-R",
                            ".gnu.switches.text.cl_args",
                            "-R",
                            ".gnu.switches.text.lipo_info",
                            "-R",
                            ".gnu.switches.text.annotation",
                        ],
                    ),
                    flag_group(
                        flags = ["%{stripopts}"],
                        iterate_over = "stripopts",
                    ),
                    flag_group(flags = ["%{input_file}"]),
                ],
            ),
        ],
        tools = [tool(path = "/usr/bin/strip")],
    )

    objcopy_embed_data_action = action_config(
        action_name = "objcopy_embed_data",
        enabled = True,
        tools = [tool(path = "/usr/bin/objcopy")],
    )

    action_configs = [
        assemble_action,
        preprocess_assemble_action,
        linkstamp_compile_action,
        c_compile_action,
        cpp_compile_action,
        cpp_header_parsing_action,
        cpp_module_compile_action,
        cpp_module_codegen_action,
        cpp_link_executable_action,
        cpp_link_nodeps_dynamic_library_action,
        cpp_link_dynamic_library_action,
        cpp_link_static_library_action,
        strip_action,
        objcopy_embed_data_action,
    ]

    no_legacy_features_feature = feature(name = "no_legacy_features")

    autofdo_feature = feature(
        name = "autofdo",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-fauto-profile=%{fdo_profile_path}",
                            "-fprofile-correction",
                        ],
                        expand_if_available = "fdo_profile_path",
                    ),
                ],
            ),
        ],
        provides = ["profile"],
    )

    supports_dynamic_linker_feature = feature(name = "supports_dynamic_linker", enabled = True)

    objcopy_embed_flags_feature = feature(
        name = "objcopy_embed_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ["objcopy_embed_data"],
                flag_groups = [flag_group(flags = ["-I", "binary"])],
            ),
        ],
    )

    pic_feature = feature(
        name = "pic",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.cpp_module_compile,
                ],
                flag_groups = [
                    flag_group(flags = ["-fPIC"], expand_if_available = "pic"),
                ],
            ),
        ],
    )

    preprocessor_defines_feature = feature(
        name = "preprocessor_defines",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-D%{preprocessor_defines}"],
                        iterate_over = "preprocessor_defines",
                    ),
                ],
            ),
        ],
    )

    fdo_prefetch_hints_feature = feature(
        name = "fdo_prefetch_hints",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.lto_backend,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Xclang-only=-mllvm",
                            "-Xclang-only=-prefetch-hints-file=%{fdo_prefetch_hints_path}",
                        ],
                        expand_if_available = "fdo_prefetch_hints_path",
                    ),
                ],
            ),
        ],
    )

    archiver_flags_feature = feature(
        name = "archiver_flags",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.cpp_link_static_library],
                flag_groups = [
                    flag_group(flags = ["rcsD"]),
                    flag_group(
                        flags = ["%{output_execpath}"],
                        expand_if_available = "output_execpath",
                    ),
                ],
            ),
            flag_set(
                actions = [ACTION_NAMES.cpp_link_static_library],
                flag_groups = [
                    flag_group(
                        iterate_over = "libraries_to_link",
                        flag_groups = [
                            flag_group(
                                flags = ["%{libraries_to_link.name}"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "object_file",
                                ),
                            ),
                            flag_group(
                                flags = ["%{libraries_to_link.object_files}"],
                                iterate_over = "libraries_to_link.object_files",
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "object_file_group",
                                ),
                            ),
                        ],
                        expand_if_available = "libraries_to_link",
                    ),
                ],
            ),
        ],
    )

    strip_debug_symbols_feature = feature(
        name = "strip_debug_symbols",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-Wl,-S"],
                        expand_if_available = "strip_debug_symbols",
                    ),
                ],
            ),
        ],
    )

    unfiltered_compile_flags_feature = feature(
        name = "unfiltered_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-no-canonical-prefixes",
                            "-Wno-builtin-macro-redefined",
                            "-D__DATE__=\"redacted\"",
                            "-D__TIMESTAMP__=\"redacted\"",
                            "-D__TIME__=\"redacted\"",
                        ],
                    ),
                ],
            ),
        ],
    )

    per_object_debug_info_feature = feature(
        name = "per_object_debug_info",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_codegen,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-gsplit-dwarf"],
                        expand_if_available = "per_object_debug_info_file",
                    ),
                ],
            ),
        ],
    )

    libraries_to_link_feature = feature(
        name = "libraries_to_link",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        iterate_over = "libraries_to_link",
                        flag_groups = [
                            flag_group(
                                flags = ["-Wl,--start-lib"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "object_file_group",
                                ),
                            ),
                            flag_group(
                                flags = ["-Wl,-whole-archive"],
                                expand_if_true = "libraries_to_link.is_whole_archive",
                            ),
                            flag_group(
                                flags = ["%{libraries_to_link.object_files}"],
                                iterate_over = "libraries_to_link.object_files",
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "object_file_group",
                                ),
                            ),
                            flag_group(
                                flags = ["%{libraries_to_link.name}"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "object_file",
                                ),
                            ),
                            flag_group(
                                flags = ["%{libraries_to_link.name}"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "interface_library",
                                ),
                            ),
                            flag_group(
                                flags = ["%{libraries_to_link.name}"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "static_library",
                                ),
                            ),
                            flag_group(
                                flags = ["-l%{libraries_to_link.name}"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "dynamic_library",
                                ),
                            ),
                            flag_group(
                                flags = ["-l:%{libraries_to_link.name}"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "versioned_dynamic_library",
                                ),
                            ),
                            flag_group(
                                flags = ["-Wl,-no-whole-archive"],
                                expand_if_true = "libraries_to_link.is_whole_archive",
                            ),
                            flag_group(
                                flags = ["-Wl,--end-lib"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "object_file_group",
                                ),
                            ),
                        ],
                        expand_if_available = "libraries_to_link",
                    ),
                    flag_group(
                        flags = ["-Wl,@%{thinlto_param_file}"],
                        expand_if_available = "libraries_to_link",
                        expand_if_true = "thinlto_param_file",
                    ),
                ],
            ),
        ],
    )

    fission_support_feature = feature(
        name = "fission_support",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-Wl,--gdb-index"],
                        expand_if_available = "is_using_fission",
                    ),
                ],
            ),
        ],
    )

    dbg_feature = feature(name = "dbg")

    shared_flag_feature = feature(
        name = "shared_flag",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                ],
                flag_groups = [flag_group(flags = ["-shared"])],
            ),
        ],
    )

    user_link_flags_feature = feature(
        name = "user_link_flags",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["%{user_link_flags}"],
                        iterate_over = "user_link_flags",
                        expand_if_available = "user_link_flags",
                    ),
                ],
            ),
        ],
    )

    coverage_feature = feature(
        name = "coverage",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                ],
                flag_groups = [flag_group(flags = ["--coverage"])],
            ),
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ACTION_NAMES.cpp_link_executable,
                ],
                flag_groups = [flag_group(flags = ["--coverage"])],
            ),
        ],
        provides = ["profile"],
    )

    user_compile_flags_feature = feature(
        name = "user_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["%{user_compile_flags}"],
                        iterate_over = "user_compile_flags",
                        expand_if_available = "user_compile_flags",
                    ),
                ],
            ),
        ],
    )

    compiler_input_flags_feature = feature(
        name = "compiler_input_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.objc_compile,
                    ACTION_NAMES.objcpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.lto_backend,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-c", "%{source_file}"],
                        expand_if_available = "source_file",
                    ),
                ],
            ),
        ],
    )

    compiler_output_flags_feature = feature(
        name = "compiler_output_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.objc_compile,
                    ACTION_NAMES.objcpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.lto_backend,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-S"],
                        expand_if_available = "output_assembly_file",
                    ),
                    flag_group(
                        flags = ["-E"],
                        expand_if_available = "output_preprocess_file",
                    ),
                    flag_group(
                        flags = ["-o", "%{output_file}"],
                        expand_if_available = "output_file",
                    ),
                ],
            ),
        ],
    )

    opt_feature = feature(name = "opt")

    include_paths_feature = feature(
        name = "include_paths",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.clif_match,
                    ACTION_NAMES.objc_compile,
                    ACTION_NAMES.objcpp_compile,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-iquote", "%{quote_include_paths}"],
                        iterate_over = "quote_include_paths",
                    ),
                    flag_group(
                        flags = ["-I%{include_paths}"],
                        iterate_over = "include_paths",
                    ),
                    flag_group(
                        flags = ["-isystem", "%{system_include_paths}"],
                        iterate_over = "system_include_paths",
                    ),
                ],
            ),
        ],
    )

    fdo_instrument_feature = feature(
        name = "fdo_instrument",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ACTION_NAMES.cpp_link_executable,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-fprofile-generate=%{fdo_instrument_path}",
                            "-fno-data-sections",
                        ],
                        expand_if_available = "fdo_instrument_path",
                    ),
                ],
            ),
        ],
        provides = ["profile"],
    )

    library_search_directories_feature = feature(
        name = "library_search_directories",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-L%{library_search_directories}"],
                        iterate_over = "library_search_directories",
                        expand_if_available = "library_search_directories",
                    ),
                ],
            ),
        ],
    )

    default_link_flags_feature = feature(
        name = "default_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-fuse-ld=gold",
                            "-Wl,-no-as-needed",
                            "-Wl,-z,relro,-z,now",
                            "-B/usr/local/bin",
                            "-lstdc++",
                            "-lm",
                        ],
                    ),
                ],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["-Wl,--gc-sections"])],
                with_features = [with_feature_set(features = ["opt"])],
            ),
        ],
    )

    default_compile_flags_feature = feature(
        name = "default_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-U_FORTIFY_SOURCE",
                            "-fstack-protector",
                            "-Wall",
                            "-Wthread-safety",
                            "-Wself-assign",
                            "-fcolor-diagnostics",
                            "-fno-omit-frame-pointer",
                        ],
                    ),
                ],
            ),
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [flag_group(flags = ["-g"])],
                with_features = [with_feature_set(features = ["dbg"])],
            ),
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-g0",
                            "-O2",
                            "-D_FORTIFY_SOURCE=1",
                            "-DNDEBUG",
                            "-ffunction-sections",
                            "-fdata-sections",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["opt"])],
            ),
            flag_set(
                actions = [
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [flag_group(flags = ["-std=c++0x"])],
            ),
        ],
    )

    static_link_cpp_runtimes_feature = feature(name = "static_link_cpp_runtimes")

    dependency_file_feature = feature(
        name = "dependency_file",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.objc_compile,
                    ACTION_NAMES.objcpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-MD", "-MF", "%{dependency_file}"],
                        expand_if_available = "dependency_file",
                    ),
                ],
            ),
        ],
    )

    random_seed_feature = feature(
        name = "random_seed",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.cpp_module_compile,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-frandom-seed=%{output_file}"],
                        expand_if_available = "output_file",
                    ),
                ],
            ),
        ],
    )

    runtime_library_search_directories_feature = feature(
        name = "runtime_library_search_directories",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        iterate_over = "runtime_library_search_directories",
                        flag_groups = [
                            flag_group(
                                flags = [
                                    "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}",
                                ],
                            ),
                        ],
                        expand_if_available = "runtime_library_search_directories",
                    ),
                ],
            ),
        ],
    )

    fully_static_link_feature = feature(
        name = "fully_static_link",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_link_executable,
                    ACTION_NAMES.cpp_link_dynamic_library,
                ],
                flag_groups = [flag_group(flags = ["-static"])],
            ),
        ],
    )

    sysroot_feature = feature(
        name = "sysroot",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_link_executable,
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ACTION_NAMES.clif_match,
                    ACTION_NAMES.lto_backend,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["--sysroot=%{sysroot}"],
                        expand_if_available = "sysroot",
                    ),
                ],
            ),
        ],
    )

    supports_start_end_lib_feature = feature(name = "supports_start_end_lib", enabled = True)

    symbol_counts_feature = feature(
        name = "symbol_counts",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-Wl,--print-symbol-counts=%{symbol_counts_output}"],
                        expand_if_available = "symbol_counts_output",
                    ),
                ],
            ),
        ],
    )

    linkstamps_feature = feature(
        name = "linkstamps",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["%{linkstamp_paths}"],
                        iterate_over = "linkstamp_paths",
                        expand_if_available = "linkstamp_paths",
                    ),
                ],
            ),
        ],
    )

    output_execpath_flags_feature = feature(
        name = "output_execpath_flags",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ACTION_NAMES.cpp_link_executable,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-o", "%{output_execpath}"],
                        expand_if_available = "output_execpath",
                    ),
                ],
            ),
        ],
    )

    force_pic_flags_feature = feature(
        name = "force_pic_flags",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.cpp_link_executable],
                flag_groups = [
                    flag_group(
                        flags = ["-pie"],
                        expand_if_available = "force_pic",
                    ),
                ],
            ),
        ],
    )

    fdo_optimize_feature = feature(
        name = "fdo_optimize",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-fprofile-use=%{fdo_profile_path}",
                            "-fprofile-correction",
                        ],
                        expand_if_available = "fdo_profile_path",
                    ),
                ],
            ),
        ],
        provides = ["profile"],
    )

    linker_param_file_feature = feature(
        name = "linker_param_file",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-Wl,@%{linker_param_file}"],
                        expand_if_available = "linker_param_file",
                    ),
                ],
            ),
            flag_set(
                actions = [ACTION_NAMES.cpp_link_static_library],
                flag_groups = [
                    flag_group(
                        flags = ["@%{linker_param_file}"],
                        expand_if_available = "linker_param_file",
                    ),
                ],
            ),
        ],
    )

    includes_feature = feature(
        name = "includes",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.clif_match,
                    ACTION_NAMES.objc_compile,
                    ACTION_NAMES.objcpp_compile,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-include", "%{includes}"],
                        iterate_over = "includes",
                        expand_if_available = "includes",
                    ),
                ],
            ),
        ],
    )

    supports_pic_feature = feature(name = "supports_pic", enabled = True)

    features = [
        no_legacy_features_feature,
        default_compile_flags_feature,
        static_link_cpp_runtimes_feature,
        dependency_file_feature,
        random_seed_feature,
        pic_feature,
        per_object_debug_info_feature,
        preprocessor_defines_feature,
        includes_feature,
        include_paths_feature,
        fdo_instrument_feature,
        fdo_prefetch_hints_feature,
        autofdo_feature,
        symbol_counts_feature,
        shared_flag_feature,
        linkstamps_feature,
        output_execpath_flags_feature,
        runtime_library_search_directories_feature,
        library_search_directories_feature,
        archiver_flags_feature,
        libraries_to_link_feature,
        force_pic_flags_feature,
        user_link_flags_feature,
        default_link_flags_feature,
        fission_support_feature,
        strip_debug_symbols_feature,
        coverage_feature,
        fdo_optimize_feature,
        fully_static_link_feature,
        user_compile_flags_feature,
        sysroot_feature,
        unfiltered_compile_flags_feature,
        linker_param_file_feature,
        compiler_input_flags_feature,
        compiler_output_flags_feature,
        supports_dynamic_linker_feature,
        supports_start_end_lib_feature,
        supports_pic_feature,
        objcopy_embed_flags_feature,
        opt_feature,
        dbg_feature,
    ]

    cxx_builtin_include_directories = [
        "/usr/local/include",
        "/usr/local/lib/clang/9.0.0/include",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
        "/usr/include/c++/5.4.0",
        "/usr/include/x86_64-linux-gnu/c++/5.4.0",
        "/usr/include/c++/5.4.0/backward",
    ]

    artifact_name_patterns = [
        artifact_name_pattern(
            category_name = "static_library",
            prefix = "lib",
            extension = ".a",
        ),
        artifact_name_pattern(
            category_name = "alwayslink_static_library",
            prefix = "lib",
            extension = ".lo",
        ),
        artifact_name_pattern(
            category_name = "dynamic_library",
            prefix = "lib",
            extension = ".so",
        ),
        artifact_name_pattern(
            category_name = "executable",
            prefix = "",
            extension = "",
        ),
        artifact_name_pattern(
            category_name = "interface_library",
            prefix = "lib",
            extension = ".ifso",
        ),
        artifact_name_pattern(
            category_name = "pic_file",
            prefix = "",
            extension = ".pic",
        ),
        artifact_name_pattern(
            category_name = "included_file_list",
            prefix = "",
            extension = ".d",
        ),
        artifact_name_pattern(
            category_name = "object_file",
            prefix = "",
            extension = ".o",
        ),
        artifact_name_pattern(
            category_name = "pic_object_file",
            prefix = "",
            extension = ".pic.o",
        ),
        artifact_name_pattern(
            category_name = "cpp_module",
            prefix = "",
            extension = ".pcm",
        ),
        artifact_name_pattern(
            category_name = "generated_assembly",
            prefix = "",
            extension = ".s",
        ),
        artifact_name_pattern(
            category_name = "processed_header",
            prefix = "",
            extension = ".processed",
        ),
        artifact_name_pattern(
            category_name = "generated_header",
            prefix = "",
            extension = ".h",
        ),
        artifact_name_pattern(
            category_name = "preprocessed_c_source",
            prefix = "",
            extension = ".i",
        ),
        artifact_name_pattern(
            category_name = "preprocessed_cpp_source",
            prefix = "",
            extension = ".ii",
        ),
        artifact_name_pattern(
            category_name = "coverage_data_file",
            prefix = "",
            extension = ".gcno",
        ),
        artifact_name_pattern(
            category_name = "clif_output_proto",
            prefix = "",
            extension = ".opb",
        ),
    ]

    make_variables = []

    tool_paths = [
        tool_path(name = "ar", path = "/usr/bin/ar"),
        tool_path(name = "ld", path = "/usr/bin/ld"),
        tool_path(name = "cpp", path = "/usr/bin/cpp"),
        tool_path(name = "gcc", path = "/usr/local/bin/clang"),
        tool_path(name = "dwp", path = "/usr/bin/dwp"),
        tool_path(name = "gcov", path = "/usr/bin/gcov"),
        tool_path(name = "nm", path = "/usr/bin/nm"),
        tool_path(name = "objcopy", path = "/usr/bin/objcopy"),
        tool_path(name = "objdump", path = "/usr/bin/objdump"),
        tool_path(name = "strip", path = "/usr/bin/strip"),
    ]

    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(out, "Fake executable")
    return [
        cc_common.create_cc_toolchain_config_info(
            ctx = ctx,
            features = features,
            action_configs = action_configs,
            artifact_name_patterns = artifact_name_patterns,
            cxx_builtin_include_directories = cxx_builtin_include_directories,
            toolchain_identifier = toolchain_identifier,
            host_system_name = host_system_name,
            target_system_name = target_system_name,
            target_cpu = target_cpu,
            target_libc = target_libc,
            compiler = compiler,
            abi_version = abi_version,
            abi_libc_version = abi_libc_version,
            tool_paths = tool_paths,
            make_variables = make_variables,
            builtin_sysroot = builtin_sysroot,
            cc_target_os = cc_target_os,
        ),
        DefaultInfo(
            executable = out,
        ),
    ]

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "cpu": attr.string(mandatory = True, values = ["k8"]),
    },
    provides = [CcToolchainConfigInfo],
    executable = True,
)
