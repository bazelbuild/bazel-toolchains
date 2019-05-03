"""Provides a function that maps from clang container names to the digest of
their latest available container.
"""

def toolchain_container_sha256s():
    return {
        ###########################################################
        # Clang images                                            #
        ###########################################################
        # marketplace.gcr.io/google/clang-debian8@sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395
        # Debian8 Clang configs are deprecated. No need to update this SHA for
        # config release purpose anymore.
        "debian8_clang": "sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395",

        # marketplace.gcr.io/google/clang-ubuntu:latest
        "ubuntu16_04_clang": "sha256:ed21de14f213a6dfe55c50663ae5f95c545ae0f8fce065a70ffe6d8bb260d8d6",
    }
