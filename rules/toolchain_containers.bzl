def toolchain_container_sha256s():
    return {
        ###########################################################
        # Base images                                             #
        ###########################################################
        # gcr.io/cloud-marketplace/google/debian8:latest
        "debian8": "sha256:a6df7738c401aef6bf9c113eb1eea7f3921417fd4711ea28100681f2fe483ea2",
        # gcr.io/cloud-marketplace/google/debian9:latest
        "debian9": "sha256:1d6a9a6d106bd795098f60f4abb7083626354fa6735e81743c7f8cfca11259f0",
        # gcr.io/cloud-marketplace/google/ubuntu16_04:latest
        "ubuntu16_04": "sha256:9f9775c124417057fd58d28835b42b30f5d0410530256d857b12eae640d0a359",

        ###########################################################
        # Python3 images                                          #
        ###########################################################
        # l.gcr.io/google/python:latest
        "debian8_python3": "sha256:ace668f0f01e5e562ad09c3f128488ec33fa9126313f16505a86ae77865d1696",
        # gcr.io/google-appengine/python:latest
        "ubuntu16_04_python3": "sha256:73f43d9b52e95c821dcd2d6e1bc42ebb1b002623263cea5ae517e6f81d56bc37",
    }
