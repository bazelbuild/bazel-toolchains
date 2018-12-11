def toolchain_container_sha256s():
    return {
        ###########################################################
        # Base images                                             #
        ###########################################################
        # gcr.io/cloud-marketplace/google/debian8:latest
        "debian8": "sha256:a6df7738c401aef6bf9c113eb1eea7f3921417fd4711ea28100681f2fe483ea2",
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
        "ubuntu16_04_python3": "sha256:1bbed7b5511bb582a2a8adf6a111defce8d184987c20d6281ce2bacaf2d4f71d",

        ###########################################################
        # Clang images                                            #
        ###########################################################
        # gcr.io/cloud-marketplace/google/clang-debian8
        "debian8_clang": "sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395",
        # gcr.io/cloud-marketplace/google/clang-ubuntu
        "ubuntu16_04_clang": "sha256:9fe84f7c726419ab77a9680887ec4a518d1910a28284c2955620258db01c7aae",
    }

# Update only when the container in Cloud Marketplace is made available.
# List of tags and SHAs of gcr.io/cloud-marketplace/google/rbe-debian8
def public_rbe_debian8_sha256s():
    return {
        "latest": "sha256:cda3a8608d0fc545dffc6c68f6cfab8eda280c7a1558bde0753ed2e8e3006224",
        "r346485": "sha256:cda3a8608d0fc545dffc6c68f6cfab8eda280c7a1558bde0753ed2e8e3006224",
        "r342117": "sha256:4893599fb00089edc8351d9c26b31d3f600774cb5addefb00c70fdb6ca797abf",
        "r340178": "sha256:75ba06b78aa99e58cfb705378c4e3d6f0116052779d00628ecb73cd35b5ea77d",
        "r337145": "sha256:46c4fd30ed413f16a8be697833f7c07997c61997c0dceda651e9167068ca2cd3",
        "r328903": "sha256:0d5db936f8fa04638ca31e4fc117415068dca43dc343d605c0db2a15f433a327",
        "r327695": "sha256:d84a7de5175a22505209f56b02f1da20ccec64880da09ee38eaef3670fbd2a56",
        "r324073": "sha256:1ede2a929b44d629ec5abe86eee6d7ffea1d5a4d247489a8867d46cfde3e38bd",
        "r322167": "sha256:b2d946c1ddc20af250fe85cf98bd648ac5519131659f7c36e64184b433175a33",
        "r319946": "sha256:496193842f61c9494be68bd624e47c74d706cabf19a693c4653ffe96a97e43e3",
    }
