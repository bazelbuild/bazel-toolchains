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

# This Dockerfile produces a customized container builder combining
# gcr.io/cloud-builders/{bazel+gcloud}, see
# - https://github.com/GoogleCloudPlatform/cloud-builders/blob/master/gcloud/Dockerfile
# - https://github.com/GoogleCloudPlatform/cloud-builders/blob/master/bazel/Dockerfile

# TODO(xingao): switch to using rbe-debian8 once it supports docker.
FROM gcr.io/cloud-builders/bazel

ARG bazel_version

RUN apt-get -y update && \
    apt-get -y install gcc python2.7 python-dev python-setuptools wget ca-certificates \
       # These are necessary for add-apt-respository
       software-properties-common python-software-properties && \

    # Install Git >2.0.1
    add-apt-repository ppa:git-core/ppa && \
    apt-get -y update && \
    apt-get -y install git && \

    # Setup Google Cloud SDK (latest)
    mkdir -p /builder && \
    wget -qO- https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz | tar zxv -C /builder && \
    CLOUDSDK_PYTHON="python2.7" /builder/google-cloud-sdk/install.sh --usage-reporting=false \
        --bash-completion=false \
        --disable-installation-options && \

    # Install additional components
    /builder/google-cloud-sdk/bin/gcloud -q components install \
        alpha beta kubectl && \
    /builder/google-cloud-sdk/bin/gcloud -q components update && \

    # install crcmod: https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod
    easy_install -U pip && \
    pip install -U crcmod && \

    # Clean up
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ~/.config/gcloud

# Install a given release version of Bazel
RUN wget https://github.com/bazelbuild/bazel/releases/download/$bazel_version/bazel-$bazel_version-installer-linux-x86_64.sh --no-verbose -O /tmp/bazel-installer.sh && \
    chmod +x /tmp/bazel-installer.sh && \
    /tmp/bazel-installer.sh

ENV PATH=/builder/google-cloud-sdk/bin/:$PATH

ENTRYPOINT ["bazel"]
