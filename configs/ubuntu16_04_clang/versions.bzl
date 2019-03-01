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

# Returns a dict with Bazel versions mapped to supported container versions.
def bazel_to_config_versions():
    return {
        "0.20.0": ["8.0.0"],
        "0.21.0": ["8.0.0"],
        "0.22.0": ["8.0.0", "9.0.0"],
        "0.23.0": ["8.0.0", "9.0.0"],
    }

# Update only when the container in Cloud Marketplace is made available.
# List of tags and SHAs of gcr.io/cloud-marketplace/google/rbe-ubuntu16-04
LATEST = "sha256:da0f21c71abce3bbb92c3a0c44c3737f007a82b60f8bd2930abc55fe64fc2729"

# Map from sha256 of rbe ubuntu16_04 to corresponding container version.
def container_to_config_version():
    return {
        "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c": "8.0.0",
        "sha256:9bd8ba020af33edb5f11eff0af2f63b3bcb168cd6566d7b27c6685e717787928": "8.0.0",
        "sha256:da0f21c71abce3bbb92c3a0c44c3737f007a82b60f8bd2930abc55fe64fc2729": "9.0.0",
        "sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375": "8.0.0",
    }
