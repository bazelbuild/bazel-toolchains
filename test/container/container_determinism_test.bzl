def container_determinism_test(name, container_name, container_sha):
  """Macro to invoke a sh_test rule with right parameters.

  Args:
      name: name of this rule.
      container_name:  name of the container
      container_sha: value of the expected sha to check against
  """

  return native.sh_test(
           name = name,
           size = "medium",
           timeout = "long",
           srcs = ["container_determinism_test.sh"],
           data = [container_name],
           tags = ["manual"],
           args = ["-c %s -s %s" % (container_name, container_sha)],
         )
