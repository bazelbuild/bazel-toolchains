load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "env_entry",
    "env_set",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "make_variable",
    "tool",
    "tool_path",
    "variable_with_value",
    "with_feature_set",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

def _impl(ctx):
    if (ctx.attr.cpu == "k8"):
        toolchain_identifier = "linux_gnu_x86"
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        toolchain_identifier = "msvc_x64"
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "mingw-gcc"):
        toolchain_identifier = "msys_x64_mingw"
    elif (ctx.attr.cpu == "armeabi-v7a"):
        toolchain_identifier = "stub_armeabi-v7a"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "armeabi-v7a"):
        host_system_name = "armeabi-v7a"
    elif (ctx.attr.cpu == "k8"):
        host_system_name = "i686-unknown-linux-gnu"
    elif (ctx.attr.cpu == "x64_windows"):
        host_system_name = "local"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "armeabi-v7a"):
        target_system_name = "armeabi-v7a"
    elif (ctx.attr.cpu == "x64_windows"):
        target_system_name = "local"
    elif (ctx.attr.cpu == "k8"):
        target_system_name = "x86_64-unknown-linux-gnu"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "armeabi-v7a"):
        target_cpu = "armeabi-v7a"
    elif (ctx.attr.cpu == "k8"):
        target_cpu = "k8"
    elif (ctx.attr.cpu == "x64_windows"):
        target_cpu = "x64_windows"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "armeabi-v7a"):
        target_libc = "armeabi-v7a"
    elif (ctx.attr.cpu == "k8"):
        target_libc = "glibc_2.19"
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "mingw-gcc"):
        target_libc = "mingw"
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        target_libc = "msvcrt"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "k8"):
        compiler = "clang"
    elif (ctx.attr.cpu == "armeabi-v7a"):
        compiler = "compiler"
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "mingw-gcc"):
        compiler = "mingw-gcc"
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        compiler = "msvc-cl"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "armeabi-v7a"):
        abi_version = "armeabi-v7a"
    elif (ctx.attr.cpu == "k8"):
        abi_version = "clang"
    elif (ctx.attr.cpu == "x64_windows"):
        abi_version = "local"
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "armeabi-v7a"):
        abi_libc_version = "armeabi-v7a"
    elif (ctx.attr.cpu == "k8"):
        abi_libc_version = "glibc_2.19"
    elif (ctx.attr.cpu == "x64_windows"):
        abi_libc_version = "local"
    else:
        fail("Unreachable")

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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        cpp_link_nodeps_dynamic_library_action = action_config(
            action_name = ACTION_NAMES.cpp_link_nodeps_dynamic_library,
            implies = [
                "nologo",
                "shared_flag",
                "linkstamps",
                "output_execpath_flags",
                "input_param_flags",
                "user_link_flags",
                "linker_subsystem_flag",
                "linker_param_file",
                "msvc_env",
                "no_stripping",
                "has_configured_linker_path",
                "def_file",
            ],
            tools = [tool(path = "NOT_USED")],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        c_compile_action = action_config(
            action_name = ACTION_NAMES.c_compile,
            implies = [
                "compiler_input_flags",
                "compiler_output_flags",
                "nologo",
                "msvc_env",
                "parse_showincludes",
                "user_compile_flags",
                "sysroot",
                "unfiltered_compile_flags",
            ],
            tools = [tool(path = "NOT_USED")],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        cpp_compile_action = action_config(
            action_name = ACTION_NAMES.cpp_compile,
            implies = [
                "compiler_input_flags",
                "compiler_output_flags",
                "nologo",
                "msvc_env",
                "parse_showincludes",
                "user_compile_flags",
                "sysroot",
                "unfiltered_compile_flags",
            ],
            tools = [tool(path = "NOT_USED")],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        cpp_link_dynamic_library_action = action_config(
            action_name = ACTION_NAMES.cpp_link_dynamic_library,
            implies = [
                "nologo",
                "shared_flag",
                "linkstamps",
                "output_execpath_flags",
                "input_param_flags",
                "user_link_flags",
                "linker_subsystem_flag",
                "linker_param_file",
                "msvc_env",
                "no_stripping",
                "has_configured_linker_path",
                "def_file",
            ],
            tools = [tool(path = "NOT_USED")],
        )
    elif (ctx.attr.cpu == "k8"):
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

    objcopy_embed_data_action = action_config(
        action_name = "objcopy_embed_data",
        enabled = True,
        tools = [tool(path = "/usr/bin/objcopy")],
    )

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        preprocess_assemble_action = action_config(
            action_name = ACTION_NAMES.preprocess_assemble,
            implies = [
                "compiler_input_flags",
                "compiler_output_flags",
                "nologo",
                "msvc_env",
                "sysroot",
            ],
            tools = [tool(path = "NOT_USED")],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        cpp_link_executable_action = action_config(
            action_name = ACTION_NAMES.cpp_link_executable,
            implies = [
                "nologo",
                "linkstamps",
                "output_execpath_flags",
                "input_param_flags",
                "user_link_flags",
                "linker_subsystem_flag",
                "linker_param_file",
                "msvc_env",
                "no_stripping",
            ],
            tools = [tool(path = "NOT_USED")],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        assemble_action = action_config(
            action_name = ACTION_NAMES.assemble,
            implies = [
                "compiler_input_flags",
                "compiler_output_flags",
                "nologo",
                "msvc_env",
                "sysroot",
            ],
            tools = [tool(path = "NOT_USED")],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        cpp_link_static_library_action = action_config(
            action_name = ACTION_NAMES.cpp_link_static_library,
            implies = [
                "nologo",
                "archiver_flags",
                "input_param_flags",
                "linker_param_file",
                "msvc_env",
            ],
            tools = [tool(path = "NOT_USED")],
        )
    elif (ctx.attr.cpu == "k8"):
        cpp_link_static_library_action = action_config(
            action_name = ACTION_NAMES.cpp_link_static_library,
            implies = ["archiver_flags", "linker_param_file"],
            tools = [tool(path = "/usr/bin/ar")],
        )

    if (ctx.attr.cpu == "armeabi-v7a"
        or ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "mingw-gcc"):
        action_configs = []
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        action_configs = [
                assemble_action,
                preprocess_assemble_action,
                c_compile_action,
                cpp_compile_action,
                cpp_link_executable_action,
                cpp_link_dynamic_library_action,
                cpp_link_nodeps_dynamic_library_action,
                cpp_link_static_library_action,
            ]
    elif (ctx.attr.cpu == "k8"):
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
    else:
        fail("Unreachable")

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

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        shared_flag_feature = feature(
            name = "shared_flag",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = [flag_group(flags = ["/DLL"])],
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

    frame_pointer_feature = feature(
        name = "frame_pointer",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/Oy-"])],
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

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        user_compile_flags_feature = feature(
            name = "user_compile_flags",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
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

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        unfiltered_compile_flags_feature = feature(
            name = "unfiltered_compile_flags",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["%{unfiltered_compile_flags}"],
                            iterate_over = "unfiltered_compile_flags",
                            expand_if_available = "unfiltered_compile_flags",
                        ),
                    ],
                ),
            ],
        )

    static_link_msvcrt_feature = feature(name = "static_link_msvcrt")

    no_legacy_features_feature = feature(name = "no_legacy_features")

    targets_windows_feature = feature(
        name = "targets_windows",
        enabled = True,
        implies = ["copy_dynamic_libraries_to_binary"],
    )

    msvc_compile_env_feature = feature(
        name = "msvc_compile_env",
        env_sets = [
            env_set(
                actions = [
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                ],
                env_entries = [env_entry(key = "INCLUDE", value = "")],
            ),
        ],
    )

    linker_subsystem_flag_feature = feature(
        name = "linker_subsystem_flag",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["/SUBSYSTEM:CONSOLE"])],
            ),
        ],
    )

    copy_dynamic_libraries_to_binary_feature = feature(name = "copy_dynamic_libraries_to_binary")

    generate_pdb_file_feature = feature(
        name = "generate_pdb_file",
        requires = [
            feature_set(features = ["dbg"]),
            feature_set(features = ["fastbuild"]),
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

    supports_start_end_lib_feature = feature(name = "supports_start_end_lib", enabled = True)

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        dbg_feature = feature(
            name = "dbg",
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                    flag_groups = [flag_group(flags = ["/Od", "/Z7"])],
                ),
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [flag_group(flags = ["", "/INCREMENTAL:NO"])],
                ),
            ],
            implies = ["generate_pdb_file"],
        )
    elif (ctx.attr.cpu == "k8"):
        dbg_feature = feature(name = "dbg")

    msvc_env_feature = feature(
        name = "msvc_env",
        env_sets = [
            env_set(
                actions = [
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.cpp_link_executable,
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ACTION_NAMES.cpp_link_static_library,
                ],
                env_entries = [
                    env_entry(key = "PATH", value = ""),
                    env_entry(key = "TMP", value = ""),
                    env_entry(key = "TEMP", value = ""),
                ],
            ),
        ],
        implies = ["msvc_compile_env", "msvc_link_env"],
    )

    supports_interface_shared_libraries_feature = feature(
        name = "supports_interface_shared_libraries",
        enabled = True,
    )

    supports_dynamic_linker_feature = feature(name = "supports_dynamic_linker", enabled = True)

    dynamic_link_msvcrt_debug_feature = feature(
        name = "dynamic_link_msvcrt_debug",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/MDd"])],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["/DEFAULTLIB:msvcrtd.lib"])],
            ),
        ],
        requires = [feature_set(features = ["dbg"])],
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

    nologo_feature = feature(
        name = "nologo",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.cpp_link_executable,
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ACTION_NAMES.cpp_link_static_library,
                ],
                flag_groups = [flag_group(flags = ["/nologo"])],
            ),
        ],
    )

    fastbuild_feature = feature(
        name = "fastbuild",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/Od", "/Z7"])],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["", "/INCREMENTAL:NO"])],
            ),
        ],
        implies = ["generate_pdb_file"],
    )

    determinism_feature = feature(
        name = "determinism",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [
                    flag_group(
                        flags = [
                            "/wd4117",
                            "-D__DATE__=\"redacted\"",
                            "-D__TIMESTAMP__=\"redacted\"",
                            "-D__TIME__=\"redacted\"",
                        ],
                    ),
                ],
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

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        compiler_output_flags_feature = feature(
            name = "compiler_output_flags",
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.assemble],
                    flag_groups = [
                        flag_group(
                            flag_groups = [
                                flag_group(
                                    flags = ["/Fo%{output_file}", "/Zi"],
                                    expand_if_not_available = "output_preprocess_file",
                                ),
                            ],
                            expand_if_available = "output_file",
                            expand_if_not_available = "output_assembly_file",
                        ),
                    ],
                ),
                flag_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                    ],
                    flag_groups = [
                        flag_group(
                            flag_groups = [
                                flag_group(
                                    flags = ["/Fo%{output_file}"],
                                    expand_if_not_available = "output_preprocess_file",
                                ),
                            ],
                            expand_if_available = "output_file",
                            expand_if_not_available = "output_assembly_file",
                        ),
                        flag_group(
                            flag_groups = [
                                flag_group(
                                    flags = ["/Fa%{output_file}"],
                                    expand_if_available = "output_assembly_file",
                                ),
                            ],
                            expand_if_available = "output_file",
                        ),
                        flag_group(
                            flag_groups = [
                                flag_group(
                                    flags = ["/P", "/Fi%{output_file}"],
                                    expand_if_available = "output_preprocess_file",
                                ),
                            ],
                            expand_if_available = "output_file",
                        ),
                    ],
                ),
            ],
        )

    parse_showincludes_feature = feature(
        name = "parse_showincludes",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_header_parsing,
                ],
                flag_groups = [flag_group(flags = ["/showIncludes"])],
            ),
        ],
    )

    def_file_feature = feature(
        name = "def_file",
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["/DEF:%{def_file_path}", "/ignore:4070"],
                        expand_if_available = "def_file_path",
                    ),
                ],
            ),
        ],
    )

    windows_export_all_symbols_feature = feature(name = "windows_export_all_symbols")

    no_stripping_feature = feature(name = "no_stripping")

    msvc_link_env_feature = feature(
        name = "msvc_link_env",
        env_sets = [
            env_set(
                actions = all_link_actions +
                    [ACTION_NAMES.cpp_link_static_library],
                env_entries = [env_entry(key = "LIB", value = "")],
            ),
        ],
    )

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
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
                                "/DCOMPILER_MSVC",
                                "/DNOMINMAX",
                                "/D_WIN32_WINNT=0x0601",
                                "/D_CRT_SECURE_NO_DEPRECATE",
                                "/D_CRT_SECURE_NO_WARNINGS",
                                "/bigobj",
                                "/Zm500",
                                "/EHsc",
                                "/wd4351",
                                "/wd4291",
                                "/wd4250",
                                "/wd4996",
                            ],
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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        archiver_flags_feature = feature(
            name = "archiver_flags",
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.cpp_link_static_library],
                    flag_groups = [
                        flag_group(
                            flags = ["/OUT:%{output_execpath}"],
                            expand_if_available = "output_execpath",
                        ),
                    ],
                ),
            ],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        compiler_input_flags_feature = feature(
            name = "compiler_input_flags",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["/c", "%{source_file}"],
                            expand_if_available = "source_file",
                        ),
                    ],
                ),
            ],
        )

    smaller_binary_feature = feature(
        name = "smaller_binary",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/Gy", "/Gw"])],
                with_features = [with_feature_set(features = ["opt"])],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["/OPT:ICF", "/OPT:REF"])],
                with_features = [with_feature_set(features = ["opt"])],
            ),
        ],
    )

    no_windows_export_all_symbols_feature = feature(name = "no_windows_export_all_symbols")

    static_link_msvcrt_no_debug_feature = feature(
        name = "static_link_msvcrt_no_debug",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/MT"])],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["/DEFAULTLIB:libcmt.lib"])],
            ),
        ],
        requires = [
            feature_set(features = ["fastbuild"]),
            feature_set(features = ["opt"]),
        ],
    )

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        preprocessor_defines_feature = feature(
            name = "preprocessor_defines",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["/D%{preprocessor_defines}"],
                            iterate_over = "preprocessor_defines",
                        ),
                    ],
                ),
            ],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        output_execpath_flags_feature = feature(
            name = "output_execpath_flags",
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [
                        flag_group(
                            flags = ["/OUT:%{output_execpath}"],
                            expand_if_available = "output_execpath",
                        ),
                    ],
                ),
            ],
        )

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        linker_param_file_feature = feature(
            name = "linker_param_file",
            flag_sets = [
                flag_set(
                    actions = all_link_actions +
                        [ACTION_NAMES.cpp_link_static_library],
                    flag_groups = [
                        flag_group(
                            flags = ["@%{linker_param_file}"],
                            expand_if_available = "linker_param_file",
                        ),
                    ],
                ),
            ],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        opt_feature = feature(
            name = "opt",
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                    flag_groups = [flag_group(flags = ["/O2"])],
                ),
            ],
            implies = ["frame_pointer"],
        )
    elif (ctx.attr.cpu == "k8"):
        opt_feature = feature(name = "opt")

    static_link_cpp_runtimes_feature = feature(name = "static_link_cpp_runtimes")

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

    has_configured_linker_path_feature = feature(name = "has_configured_linker_path")

    treat_warnings_as_errors_feature = feature(
        name = "treat_warnings_as_errors",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/WX"])],
            ),
        ],
    )

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        include_paths_feature = feature(
            name = "include_paths",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["/I%{quote_include_paths}"],
                            iterate_over = "quote_include_paths",
                        ),
                        flag_group(
                            flags = ["/I%{include_paths}"],
                            iterate_over = "include_paths",
                        ),
                        flag_group(
                            flags = ["/I%{system_include_paths}"],
                            iterate_over = "system_include_paths",
                        ),
                    ],
                ),
            ],
        )
    elif (ctx.attr.cpu == "k8"):
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

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        default_link_flags_feature = feature(
            name = "default_link_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = [flag_group(flags = ["/MACHINE:X64"])],
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

    dynamic_link_msvcrt_no_debug_feature = feature(
        name = "dynamic_link_msvcrt_no_debug",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/MD"])],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["/DEFAULTLIB:msvcrt.lib"])],
            ),
        ],
        requires = [
            feature_set(features = ["fastbuild"]),
            feature_set(features = ["opt"]),
        ],
    )

    static_link_msvcrt_debug_feature = feature(
        name = "static_link_msvcrt_debug",
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/MTd"])],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["/DEFAULTLIB:libcmtd.lib"])],
            ),
        ],
        requires = [feature_set(features = ["dbg"])],
    )

    disable_assertions_feature = feature(
        name = "disable_assertions",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile, ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = ["/DNDEBUG"])],
                with_features = [with_feature_set(features = ["opt"])],
            ),
        ],
    )

    supports_pic_feature = feature(name = "supports_pic", enabled = True)

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        sysroot_feature = feature(
            name = "sysroot",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp_link_executable,
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["--sysroot=%{sysroot}"],
                            iterate_over = "sysroot",
                            expand_if_available = "sysroot",
                        ),
                    ],
                ),
            ],
        )

    input_param_flags_feature = feature(
        name = "input_param_flags",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["/IMPLIB:%{interface_library_output_path}"],
                        expand_if_available = "interface_library_output_path",
                    ),
                ],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["%{libopts}"],
                        iterate_over = "libopts",
                        expand_if_available = "libopts",
                    ),
                ],
            ),
            flag_set(
                actions = all_link_actions +
                    [ACTION_NAMES.cpp_link_static_library],
                flag_groups = [
                    flag_group(
                        iterate_over = "libraries_to_link",
                        flag_groups = [
                            flag_group(
                                iterate_over = "libraries_to_link.object_files",
                                flag_groups = [flag_group(flags = ["%{libraries_to_link.object_files}"])],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "object_file_group",
                                ),
                            ),
                            flag_group(
                                flag_groups = [flag_group(flags = ["%{libraries_to_link.name}"])],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "object_file",
                                ),
                            ),
                            flag_group(
                                flag_groups = [flag_group(flags = ["%{libraries_to_link.name}"])],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "interface_library",
                                ),
                            ),
                            flag_group(
                                flag_groups = [
                                    flag_group(
                                        flags = ["%{libraries_to_link.name}"],
                                        expand_if_false = "libraries_to_link.is_whole_archive",
                                    ),
                                    flag_group(
                                        flags = ["/WHOLEARCHIVE:%{libraries_to_link.name}"],
                                        expand_if_true = "libraries_to_link.is_whole_archive",
                                    ),
                                ],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "static_library",
                                ),
                            ),
                        ],
                        expand_if_available = "libraries_to_link",
                    ),
                ],
            ),
        ],
    )

    ignore_noisy_warnings_feature = feature(
        name = "ignore_noisy_warnings",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.cpp_link_static_library],
                flag_groups = [flag_group(flags = ["/ignore:4221"])],
            ),
        ],
    )

    if (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        features = [
                no_legacy_features_feature,
                nologo_feature,
                has_configured_linker_path_feature,
                no_stripping_feature,
                targets_windows_feature,
                copy_dynamic_libraries_to_binary_feature,
                default_compile_flags_feature,
                msvc_env_feature,
                msvc_compile_env_feature,
                msvc_link_env_feature,
                include_paths_feature,
                preprocessor_defines_feature,
                parse_showincludes_feature,
                generate_pdb_file_feature,
                shared_flag_feature,
                linkstamps_feature,
                output_execpath_flags_feature,
                archiver_flags_feature,
                input_param_flags_feature,
                linker_subsystem_flag_feature,
                user_link_flags_feature,
                default_link_flags_feature,
                linker_param_file_feature,
                static_link_msvcrt_feature,
                static_link_msvcrt_no_debug_feature,
                dynamic_link_msvcrt_no_debug_feature,
                static_link_msvcrt_debug_feature,
                dynamic_link_msvcrt_debug_feature,
                dbg_feature,
                fastbuild_feature,
                opt_feature,
                frame_pointer_feature,
                disable_assertions_feature,
                determinism_feature,
                treat_warnings_as_errors_feature,
                smaller_binary_feature,
                ignore_noisy_warnings_feature,
                user_compile_flags_feature,
                sysroot_feature,
                unfiltered_compile_flags_feature,
                compiler_output_flags_feature,
                compiler_input_flags_feature,
                def_file_feature,
                windows_export_all_symbols_feature,
                no_windows_export_all_symbols_feature,
                supports_dynamic_linker_feature,
                supports_interface_shared_libraries_feature,
            ]
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "mingw-gcc"):
        features = [supports_dynamic_linker_feature]
    elif (ctx.attr.cpu == "armeabi-v7a"):
        features = [supports_dynamic_linker_feature, supports_pic_feature]
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "armeabi-v7a"
        or ctx.attr.cpu == "x64_windows"):
        cxx_builtin_include_directories = []
    elif (ctx.attr.cpu == "k8"):
        cxx_builtin_include_directories = [
                "/usr/local/include",
                "/usr/local/lib/clang/9.0.0/include",
                "/usr/include/x86_64-linux-gnu",
                "/usr/include",
                "/usr/include/c++/5.4.0",
                "/usr/include/x86_64-linux-gnu/c++/5.4.0",
                "/usr/include/c++/5.4.0/backward",
            ]
    else:
        fail("Unreachable")

    if (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "mingw-gcc"):
        artifact_name_patterns = [
            artifact_name_pattern(
                category_name = "executable",
                prefix = "",
                extension = ".exe",
            ),
        ]
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        artifact_name_patterns = [
            artifact_name_pattern(
                category_name = "object_file",
                prefix = "",
                extension = ".obj",
            ),
            artifact_name_pattern(
                category_name = "static_library",
                prefix = "",
                extension = ".lib",
            ),
            artifact_name_pattern(
                category_name = "alwayslink_static_library",
                prefix = "",
                extension = ".lo.lib",
            ),
            artifact_name_pattern(
                category_name = "executable",
                prefix = "",
                extension = ".exe",
            ),
            artifact_name_pattern(
                category_name = "dynamic_library",
                prefix = "",
                extension = ".dll",
            ),
            artifact_name_pattern(
                category_name = "interface_library",
                prefix = "",
                extension = ".if.lib",
            ),
        ]
    elif (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "armeabi-v7a"):
        artifact_name_patterns = []
    else:
        fail("Unreachable")

    make_variables = []

    if (ctx.attr.cpu == "armeabi-v7a"):
        tool_paths = [
            tool_path(name = "ar", path = "/bin/false"),
            tool_path(name = "compat-ld", path = "/bin/false"),
            tool_path(name = "cpp", path = "/bin/false"),
            tool_path(name = "dwp", path = "/bin/false"),
            tool_path(name = "gcc", path = "/bin/false"),
            tool_path(name = "gcov", path = "/bin/false"),
            tool_path(name = "ld", path = "/bin/false"),
            tool_path(name = "nm", path = "/bin/false"),
            tool_path(name = "objcopy", path = "/bin/false"),
            tool_path(name = "objdump", path = "/bin/false"),
            tool_path(name = "strip", path = "/bin/false"),
        ]
    elif (ctx.attr.cpu == "k8"):
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
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "msvc-cl"):
        tool_paths = [
            tool_path(name = "ar", path = "NOT_USED"),
            tool_path(name = "ml", path = "NOT_USED"),
            tool_path(name = "cpp", path = "NOT_USED"),
            tool_path(name = "gcc", path = "NOT_USED"),
            tool_path(name = "gcov", path = "wrapper/bin/msvc_nop.bat"),
            tool_path(name = "ld", path = "NOT_USED"),
            tool_path(name = "nm", path = "wrapper/bin/msvc_nop.bat"),
            tool_path(
                name = "objcopy",
                path = "wrapper/bin/msvc_nop.bat",
            ),
            tool_path(
                name = "objdump",
                path = "wrapper/bin/msvc_nop.bat",
            ),
            tool_path(
                name = "strip",
                path = "wrapper/bin/msvc_nop.bat",
            ),
        ]
    elif (ctx.attr.cpu == "x64_windows" and ctx.attr.compiler == "mingw-gcc"):
        tool_paths = []
    else:
        fail("Unreachable")


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
            cc_target_os = cc_target_os
        ),
        DefaultInfo(
            executable = out,
        ),
    ]
cc_toolchain_config_rule =  rule(
    implementation = _impl,
    attrs = {
        "cpu": attr.string(mandatory=True, values=["armeabi-v7a", "k8", "x64_windows"]),
        "compiler": attr.string(values=["mingw-gcc", "msvc-cl"]),
    },
    provides = [CcToolchainConfigInfo],
    executable = True,
)
