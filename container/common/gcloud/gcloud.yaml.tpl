schemaVersion: "2.0.0"

commandTests:
- name: 'check-gcloud'
  command: 'gcloud'
  args: ['version']
  expectedOutput: ['Google Cloud SDK {_GCLOUD_VERSION}.*']
