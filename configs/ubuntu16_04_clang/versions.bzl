# Copyright 2016 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# Returns a dict with suppported Bazel versions mapped to the config version to use.
def bazel_to_config_versions():
    return {
        "0.13.0": "1.0",
        "0.14.1": "1.0",
        "0.15.0": "1.0",
        "0.16.1": "1.1",
        "0.17.1": "1.1",
        "0.18.0": "1.1",
        "0.19.0": "1.1",
        "0.19.2": "1.1",
        "0.20.0": "1.1",
        "0.21.0": "1.1",
        "0.22.0": "1.1",
    }

# Update only when the container in Cloud Marketplace is made available.
# List of tags and SHAs of gcr.io/cloud-marketplace/google/rbe-ubuntu16-04
LATEST = "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c"

# Map from sha256 of rbe ubuntu16_04 to corresponding major container versions.
def container_to_config_version():
    return {
        "sha256:b940d4f08ea79ce9a07220754052da2ac4a4316e035d8799769cea3c24d10c66": "1.0",
        "sha256:59bf0e191a6b5cc1ab62c2224c810681d1326bad5a27b1d36c9f40113e79da7f": "1.0",
        "sha256:b348b2e63253d5e2d32613a349747f07dc82b6b1ecfb69e8c7ac81a653b857c2": "1.0",
        "sha256:9bd8ba020af33edb5f11eff0af2f63b3bcb168cd6566d7b27c6685e717787928": "1.1",
        "sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375": "1.1",
        "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c": "1.1",
    }
