"""
Defines a test rule to check images on remote repositories actually exist.
"""

def _impl(ctx):
    args = ["--image=%s" % img for img in ctx.attr.images]
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "{} {}".format(
            ctx.executable._checker.short_path,
            " ".join(args),
        ),
    )
    runfiles = ctx.runfiles(files = [ctx.executable._checker])
    return [DefaultInfo(runfiles = runfiles)]

rbe_container_test = rule(
    attrs = {
        "images": attr.string_list(
            doc = "List of fully qualified remote image names to check for existence",
        ),
        "_checker": attr.label(
            default = "//tests/rbe_repo:image_exists",
            cfg = "host",
            executable = True,
        ),
    },
    test = True,
    implementation = _impl,
)
