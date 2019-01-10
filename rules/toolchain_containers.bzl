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
# List of tags and SHAs of gcr.io/cloud-marketplace/google/rbe-ubuntu16-04
RBE_UBUNTU16_04_LATEST = "r346485"

def public_rbe_ubuntu16_04_sha256s():
    return {
        "r346485": "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c",
        "r342117": "sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375",
        "r340178": "sha256:9bd8ba020af33edb5f11eff0af2f63b3bcb168cd6566d7b27c6685e717787928",
        "r337145": "sha256:b348b2e63253d5e2d32613a349747f07dc82b6b1ecfb69e8c7ac81a653b857c2",
        "r328903": "sha256:59bf0e191a6b5cc1ab62c2224c810681d1326bad5a27b1d36c9f40113e79da7f",
        "r327695": "sha256:b940d4f08ea79ce9a07220754052da2ac4a4316e035d8799769cea3c24d10c66",
    }

def public_rbe_ubuntu16_04_config_version():
    return {
        "r346485": "1.1",
        "r342117": "1.1",
        "r340178": "1.1",
        "r337145": "1.0",
        "r328903": "1.0",
        "r327695": "1.0",
    }
