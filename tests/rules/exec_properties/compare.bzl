def _test_succeeds():
    return "exit 0"    

def _test_fails(expected, actual):
    return"""
echo "dicts don't match."
echo "Expecting:"
echo '%s'
echo "Actual:"
echo '%s'
exit 1
""" % (expected, actual)

def _compare_dicts_impl(ctx):
    if _dicts_eq(ctx.attr.expected, ctx.attr.actual):
        ctx.actions.write(
            output = ctx.outputs.executable,
            content = _test_succeeds(),
        )
    else:
        ctx.actions.write(
            output = ctx.outputs.executable,
            content = _test_fails(ctx.attr.expected, ctx.attr.actual),
        )

def _dicts_eq(dict1, dict2):
    # Both dicts are assumed to be string->string dicts
    if len(dict1.keys()) != len(dict2.keys()):
        return False
    for key, value in dict1.items():
        if dict2.get(key) != value:
            return False
    return True

compare_dicts_test = rule(
    implementation = _compare_dicts_impl,
    attrs = {
        "expected": attr.string_dict(
            mandatory=True,
            doc="The expected dictionary",
        ),
        "actual": attr.string_dict(
            mandatory=True,
            doc="The expected dictionary",
        ),
    },
    test = True,
)

