def toolchain_container_sha256s():
    return {
        ###########################################################
        # Base images                                             #
        ###########################################################
        # gcr.io/cloud-marketplace/google/debian8:latest
        "debian8": "sha256:943025384b0efebacf5473490333658dd190182e406e956ee4af65208d104332",
        # gcr.io/cloud-marketplace/google/debian9:latest
        "debian9": "sha256:6b3aa04751aa2ac3b0c7be4ee71148b66d693ad212ce6d3244bd2a2a147f314a",
        # gcr.io/cloud-marketplace/google/ubuntu16_04:latest
        "ubuntu16_04": "sha256:5125aac627c68226c6ad6083d0e3419bc6252bea1eb9d6e7258ecfd67233d655",

        ###########################################################
        # Python3 images                                          #
        ###########################################################
        # l.gcr.io/google/python:latest
        "debian8_python3": "sha256:ace668f0f01e5e562ad09c3f128488ec33fa9126313f16505a86ae77865d1696",
        # gcr.io/google-appengine/python:latest
        "ubuntu16_04_python3": "sha256:73f43d9b52e95c821dcd2d6e1bc42ebb1b002623263cea5ae517e6f81d56bc37",
    }
