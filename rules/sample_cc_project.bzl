def generate_sample_cc_project(ctx):
    """Generates a sample cc project in the repository context

    Args:
      ctx: the Bazel repository context object

    Returns
      string path to the generated project in the repository
    """

    ctx.file(
        "cc-sample-project/BUILD",
        """package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

filegroup(
    name = "srcs",
    srcs = [
        "BUILD",
        "test.cc",
    ],
)

cc_test(
    name = "test",
    srcs = ["test.cc"],
)
""",
    )
    ctx.file(
        "cc-sample-project/test.cc",
        """#include <iostream>

int main() {
  std::cout << "Hello test!" << std::endl;
  return 0;
}

""",
    )
    ctx.file("cc-sample-project/WORKSPACE", "")

    return str(ctx.path("cc-sample-project"))
