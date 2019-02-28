def toolchain_container_sha256s():
    return {
        ###########################################################
        # Clang images                                            #
        ###########################################################
        # gcr.io/cloud-marketplace/google/clang-debian8@sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395
        # Debian8 Clang configs are deprecated. No need to update this SHA for
        # config release purpose anymore.
        "debian8_clang": "sha256:e076c87e670f9a3c95e250268f160397d1cee482ec195d51e40b992b34198395",

        # gcr.io/cloud-marketplace/google/clang-ubuntu:latest
        "ubuntu16_04_clang": "sha256:963ea21d047664257c91fb0e05d9a6e9acf1481ea1874736af4d4ceed1e02a0c",
    }

# Update only when the container in Cloud Marketplace is made available.
# List of tags and SHAs of gcr.io/cloud-marketplace/google/rbe-ubuntu16-04
RBE_UBUNTU16_04_LATEST = "r352865"

def public_rbe_ubuntu16_04_sha256s():
    return {
        "r327695": "sha256:b940d4f08ea79ce9a07220754052da2ac4a4316e035d8799769cea3c24d10c66",
        "r328903": "sha256:59bf0e191a6b5cc1ab62c2224c810681d1326bad5a27b1d36c9f40113e79da7f",
        "r337145": "sha256:b348b2e63253d5e2d32613a349747f07dc82b6b1ecfb69e8c7ac81a653b857c2",
        "r340178": "sha256:9bd8ba020af33edb5f11eff0af2f63b3bcb168cd6566d7b27c6685e717787928",
        "r342117": "sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375",
        "r346485": "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c",
        "r352865": "sha256:da0f21c71abce3bbb92c3a0c44c3737f007a82b60f8bd2930abc55fe64fc2729",
    }

# Map from revisions of rbe ubuntu16_04 to corresponding major container versions.
# Kept here as it needs to be updated along with the def above.
def public_rbe_ubuntu16_04_config_version():
    return {
        "r327695": "1.0",
        "r328903": "1.0",
        "r337145": "1.0",
        "r340178": "1.1",
        "r342117": "1.1",
        "r346485": "1.1",
        "r352865": "1.2",
    }
