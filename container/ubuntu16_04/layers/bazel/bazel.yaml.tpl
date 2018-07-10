schemaVersion: "2.0.0"

commandTests:
- name: 'check-bazel'
  command: 'bazel'
  args: ['version']
  expectedOutput: ['Build label: {_BAZEL_VERSION}']
