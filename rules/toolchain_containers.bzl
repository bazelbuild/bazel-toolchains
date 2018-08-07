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
        "ubuntu16_04": "sha256:8a12cc26c62e2f9824aada8d13c1f0c2d2847d18191560e1500d651a709d6550",

        ###########################################################
        # Python3 images                                          #
        ###########################################################
        # gcr.io/cloud-marketplace/google/python:latest
        # Pinned to ace668f0f01e5e562ad09c3f128488ec33fa9126313f16505a86ae77865d1696 as it is the
        # latest *debian8* based python3 image. Newer ones are ubuntu16_04 based.
        "debian8_python3": "sha256:ace668f0f01e5e562ad09c3f128488ec33fa9126313f16505a86ae77865d1696",
        # gcr.io/google-appengine/python:latest
        "ubuntu16_04_python3": "sha256:67fd35064a812fd0ba0a6e9485410f9f2710ebf7b0787a7b350ce6a20f166bfe",

        ###########################################################
        # Clang images                                            #
        ###########################################################
        # gcr.io/cloud-marketplace/google/clang-debian8:r337145
        "debian8_clang": "sha256:de1116d36eafe16890afd64b6bc6809a3ed5b3597ed7bc857980749270894677",
        # gcr.io/cloud-marketplace/google/clang-ubuntu:r337145
        "ubuntu16_04_clang": "sha256:fbf123ca7c7696f53864da4f7d1d9470f9ef4ebfabc4344f44173d1951faee6f",
    }
