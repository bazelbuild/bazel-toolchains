

def _clang_configure(repository_ctx, workspace, libc):
    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.attr._build_tpl,
        {
            "%{workspace_name}": workspace.name,
            "%{libc_name}": libc.name,
            "%{libc_abi_version}": libc.abi_version,
            "%{libc_include_block}": libc.include_block,
        },
    )

def _clang_toolchain_repo(repository_ctx):
    repository_ctx.download_and_extract(
        repository_ctx.attr.urls,
        ".",
        repository_ctx.attr.sha256,
        repository_ctx.attr.type,
        stripPrefix = repository_ctx.attr.strip_prefix,
    )

    if repository_ctx.os.name == "linux":
        result = repository_ctx.execute(["lsb_release", "-r"])

        if result.return_code != 0:
            if result.stdout:
                print(result.stdout)
            fail(result.stderr)

        if "16.04" in result.stdout:
            workspace = repository_ctx
            libc = struct(
                abi_version = "glibc_2.48",
                name = "glibc_2.48",
                include_block = """
  # glibc includes in the system
  cxx_builtin_include_directory: "/usr/include"
""",
            )
    else:
        fail("Not yet implemented for %s" % repository_ctx.os.name)

    _clang_configure(repository_ctx, workspace, libc)


clang_toolchain_repo = repository_rule(
    implementation = _clang_toolchain_repo,
    attrs = {
        "_build_tpl": attr.label(default = "//configs/clang:BUILD.prebuilt.tpl", cfg = "host"),
        "urls": attr.string_list(),
        "sha256": attr.string(default = ""),
        "strip_prefix": attr.string(default = ""),
        "type": attr.string(default = ""),
    },
)