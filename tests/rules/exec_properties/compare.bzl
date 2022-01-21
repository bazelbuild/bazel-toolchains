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

"""This file contains a test rule compare_dicts_test for unit testing create_rbe_exec_properties_dict.

"""

def _test_succeeds():
    return "exit 0"

def _test_fails(expected, actual):
    return """
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
            mandatory = True,
            doc = "The expected dictionary",
        ),
        "actual": attr.string_dict(
            mandatory = True,
            doc = "The actual dictionary",
        ),
    },
    test = True,
)
