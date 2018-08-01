schemaVersion: "2.0.0"

commandTests:
- name: 'java-version'
  command: 'java'
  args: ['-version']
  # java outputs to stderr.
  expectedError: ["openjdk version \"1.8.*"]
- name: 'java9-version'
  command: '/usr/lib/jvm/zulu{_JDK_VERSION}-linux_x64/bin/java'
  args: ['-version']
  # java outputs to stderr.
  expectedError: ["openjdk version \"9.*"]
- name: 'check-openssl'
  command: 'openssl'
  args: ['version']
  expectedOutput: ['OpenSSL .*']

fileExistenceTests:
- name: 'OpenJDK'
  path: '/usr/lib/jvm/java-8-openjdk-amd64'
  shouldExist: true
- name: 'OpenJDK9'
  path: '/usr/lib/jvm/zulu{_JDK_VERSION}-linux_x64'
  shouldExist: true
- name: 'OpenJDK9 srcs'
  path: '/usr/src/jdk/zsrc{_JDK_VERSION}.zip'
  shouldExist: true

metadataTest:
  env:
    - key: 'JAVA_HOME'
      value: '/usr/lib/jvm/java-8-openjdk-amd64'
