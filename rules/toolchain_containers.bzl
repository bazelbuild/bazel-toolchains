def toolchain_container_sha256s():
    return {
        ###########################################################
        # Base images                                             #
        ###########################################################
        # gcr.io/cloud-marketplace/google/debian8:latest
        "debian8": "sha256:a6df7738c401aef6bf9c113eb1eea7f3921417fd4711ea28100681f2fe483ea2",
        # gcr.io/cloud-marketplace/google/debian9:latest
        "debian9": "sha256:741d18b41622814ae6eab29b0679dd45318437998213a5cb5532003846b435e1",
        # gcr.io/cloud-marketplace/google/ubuntu16_04:latest
        "ubuntu16_04": "sha256:df51b5c52d71c9867cd9c1c88c81f67a85ff87f1defe7e9b7ac5fb7d652596bf",

        ###########################################################
        # Python3 images                                          #
        ###########################################################
        # gcr.io/cloud-marketplace/google/python:latest
        # Pinned to ace668f0f01e5e562ad09c3f128488ec33fa9126313f16505a86ae77865d1696 as it is the
        # latest *debian8* based python3 image. Newer ones are ubuntu16_04 based.
        "debian8_python3": "sha256:ace668f0f01e5e562ad09c3f128488ec33fa9126313f16505a86ae77865d1696",
        # gcr.io/google-appengine/python:latest
        "ubuntu16_04_python3": "sha256:f6955b2492f3ea481a50a9a9f0995b5f84a02d8dab357d2c9dae6b366988f074",

        ###########################################################
        # Clang images                                            #
        ###########################################################
        # gcr.io/cloud-marketplace/google/clang-debian8
        "debian8_clang": "sha256:0946899544c00537b2af06790e72ba86aa39b16e0e05aef8f53ed79d1f89f2a0",
        # gcr.io/cloud-marketplace/google/clang-ubuntu
        "ubuntu16_04_clang": "sha256:79a24c15949bd5770acac41b444c5c0b7f9723dcbc708c67d87ecf71e32c9126",
    }
