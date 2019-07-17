#!/bin/bash
#
# Copyright 2017 The Bazel Authors. All rights reserved.
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
# limitations under the License.

set -ex

# Simple script that checks a list of images (passed as args)
# can be pulled with "docker pull"
# Script attempts to delete images after pulling.
for image in "$@"
do
    echo "pulling $image"
    docker pull $image
    # Try to delete, but dont fail if could not
    docker rmi $image || true
done
