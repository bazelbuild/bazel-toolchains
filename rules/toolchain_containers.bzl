def toolchain_container_sha256s():
    return {
        ###########################################################
        # Base images                                             #
        ###########################################################
        # gcr.io/cloud-marketplace/google/debian8:latest
        "debian8": "sha256:a6df7738c401aef6bf9c113eb1eea7f3921417fd4711ea28100681f2fe483ea2",

        ###########################################################
        # Clang images                                            #
        ###########################################################
        # gcr.io/cloud-marketplace/google/clang-debian8
        "debian8_clang": "sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395",
        # gcr.io/cloud-marketplace/google/ubuntu16_04:latest
        "ubuntu16_04": "sha256:df51b5c52d71c9867cd9c1c88c81f67a85ff87f1defe7e9b7ac5fb7d652596bf",
        # gcr.io/cloud-marketplace/google/clang-ubuntu
        "ubuntu16_04_clang": "sha256:9fe84f7c726419ab77a9680887ec4a518d1910a28284c2955620258db01c7aae",
    }


