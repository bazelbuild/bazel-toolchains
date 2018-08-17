schemaVersion: "2.0.0"

commandTests:
- name: 'check-bazel'
  command: 'bazel'
  args: ['version']
  expectedOutput: ['Build label: {_BAZEL_VERSION}']

fileExistenceTests:
- name: 'bazelrc'
  path: '/etc/bazel.bazelrc'
  shouldExist: true

fileContentTests:
- name: 'bazelrc-content'
  path: '/etc/bazel.bazelrc'
  expectedContents: ['.*--host_crosstool_top=@bazel_toolchains//configs/{_CONFIG_BASE}/bazel_{_BAZEL_CONFIG_VERSION}/default:toolchain.*']
