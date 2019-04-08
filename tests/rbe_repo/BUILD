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

# sh_tests below verify that the rbe_autoconfig targets have the
# right file structure in the external folder repo

sh_test(
    name = "rac_checked_in_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rac_checked_in//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rac_checked_in//test:empty",
        "@rac_checked_in//test:exported_testdata",
    ],
)

sh_test(
    name = "rac_checked_in_no_java_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rac_checked_in_no_java//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_cc_confs",
        "assert_no_java_confs",
    ],
    data = [
        "@rac_checked_in_no_java//test:empty",
        "@rac_checked_in_no_java//test:exported_testdata",
    ],
)

sh_test(
    name = "rac_checked_in_no_cc_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rac_checked_in_no_cc//test:empty)",
        "assert_basic_cofig",
        "assert_checked_in_confs",
        "assert_no_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rac_checked_in_no_cc//test:empty",
        "@rac_checked_in_no_cc//test:exported_testdata",
    ],
)

sh_test(
    name = "rac_generate_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rac_generate//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rac_generate//test:empty",
        "@rac_generate//test:exported_testdata",
    ],
)

sh_test(
    name = "rac_generate_no_java_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rac_generate_no_java//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_cc_confs",
        "assert_no_java_confs",
    ],
    data = [
        "@rac_generate_no_java//test:empty",
        "@rac_generate_no_java//test:exported_testdata",
    ],
)

sh_test(
    name = "rac_generate_no_cc_test",
    srcs = [":rbe_autoconf_checks.sh"],
    args = [
        "$(location @rac_generate_no_cc//test:empty)",
        "assert_basic_cofig",
        "assert_no_checked_in_confs",
        "assert_no_cc_confs",
        "assert_java_confs",
    ],
    data = [
        "@rac_generate_no_cc//test:empty",
        "@rac_generate_no_cc//test:exported_testdata",
    ],
)

# TODO(nlopezgi): Add tests that verify the contents of the produced BUILD files (alias vs targets)
# TODO(nlopezgi): Add tests that verify files were copied to output_folder
# TODO(nlopezgi): Add tests that verify copy_resources does not mount (check script)
