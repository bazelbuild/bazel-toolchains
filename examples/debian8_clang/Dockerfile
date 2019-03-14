FROM marketplace.gcr.io/google/clang-debian8@sha256:6bf186b59972019e55acb6a46da721584ae5520218b0516542efdaa1f09caccf

# Install Bazel deps
RUN apt-get update && yes | apt-get install -y \
    curl \
    pkg-config \
    python \
    unzip  \
    zip && \
    rm -rf /var/lib/apt/lists/*

# Install Java
RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list \
  && apt-get -q update \
  && apt-get -y -q --no-install-recommends install \
     ca-certificates-java=20161107'*' \
     openjdk-8-jre-headless \
     openjdk-8-jdk-headless \
  && apt-get clean \
  && rm /var/lib/apt/lists/*_*

# Install Bazel release version
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
RUN apt-get update && yes | apt-get install -y bazel && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV CC /usr/local/bin/clang
ENV GOPATH /go
