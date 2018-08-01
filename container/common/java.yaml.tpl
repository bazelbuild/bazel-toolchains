schemaVersion: "2.0.0"

commandTests:
- name: 'java-version'
  command: 'java'
  args: ['-version']
  # java outputs to stderr.
  expectedError: ["openjdk version \"1.8.*"]
- name: 'java10-version'
  command: '/usr/lib/jvm/zulu{_JDK_VERSION_DECODED}-linux_x64-allmodules/bin/java'
  args: ['-version']
  # java outputs to stderr.
  expectedError: ["openjdk version \"10.*"]
- name: 'check-openssl'
  command: 'openssl'
  args: ['version']
  expectedOutput: ['OpenSSL .*']

fileExistenceTests:
- name: 'OpenJDK'
  path: '/usr/lib/jvm/java-8-openjdk-amd64'
  shouldExist: true
- name: 'OpenJDK 10'
  path: '/usr/lib/jvm/zulu{_JDK_VERSION_DECODED}-linux_x64-allmodules'
  shouldExist: true
- name: 'OpenJDK 10 srcs'
  path: '/usr/src/jdk/zsrc{_JDK_VERSION}.zip'
  shouldExist: true

metadataTest:
  env:
    - key: 'JAVA_HOME'
      value: '/usr/lib/jvm/java-8-openjdk-amd64'
