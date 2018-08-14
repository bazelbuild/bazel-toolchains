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
  expectedContents: ['.*--host_crosstool_top=@bazel_toolchains//configs/ubuntu16_04_clang/1.0/bazel_{_CONFIG_BAZEL_VERSION}/default:toolchain.*']
