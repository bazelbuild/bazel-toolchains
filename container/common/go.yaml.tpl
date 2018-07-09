schemaVersion: "2.0.0"

commandTests:
- name: 'go-version'
  command: 'go'
  args: ['version']
  expectedOutput: ['go version go{_GOLANG_REVISION} linux/amd64']

fileExistenceTests:
- name: 'Golang'
  path: '/usr/local/go/bin/go'
  shouldExist: true

metadataTest:
  env:
    - key: 'GOPATH'
      value: '/go'
