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

# Returns a dict with mayor container versions mapped to supported bazel versions.
def config_to_bazel_versions():
    return {
        "1.0": ["0.13.0", "0.14.1", "0.15.0", "0.16.1"],
        "1.1": ["0.16.1", "0.17.1", "0.18.0", "0.19.0", "0.19.2", "0.20.0", "0.21.0"],
    }
