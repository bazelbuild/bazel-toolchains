Bazel CI
:---:
[![Build status](https://badge.buildkite.com/940075452c1c5ff91dc832664c4c8f05e6ec736916688cd894.svg?branch=master)](https://buildkite.com/bazel/bazel-toolchains-postsubmit)

# bazel-toolchains

https://github.com/bazelbuild/bazel-toolchains is a repository where Google
hosts the source code for a CLI tool that can be used to generate Bazel toolchain configs. These
configs are required to configure Bazel to issue commands that will execute inside a Docker
container via a remote execution environment.

These toolchain configs include:
* C/C++ CROSSTOOL file,
* BUILD file with toolchain rules, and
* wrapper scripts.

# rbe_configs_gen - CLI Tool to Generate Configs

[rbe_configs_gen](https://github.com/bazelbuild/bazel-toolchains/blob/master/cmd/rbe_configs_gen/rbe_configs_gen.go) is
a CLI tool written in Go that can be used to generate toolchain configs for a given combination
of Bazel release and docker image. The output of the tool are toolchain configs in one or more of
the following formats:
* Tarball
* Config files copied directly to a local directory

rbe_configs_gen requires [docker](https://docs.docker.com/get-docker/) to be installed locally and
internet access to work.

Config users are recommended to use the CLI tool to generate and self host their own configs.
Pre-generated configs will be provided for new releases of Bazel & the [RBE Ubuntu 16.04](https://console.cloud.google.com/marketplace/details/google/rbe-ubuntu16-04)
without any SLOs. See [Pre-generated Configs](#pre-generated-configs) section below for details.

The rest of this section describes how to use the rbe_configs_gen tool.

## Building

### Building using Docker on Linux (Recommended)

Use the [official Golang docker image](https://hub.docker.com/_/golang) to build the rbe_configs_gen
binary using Go 1.16. This avoids having to install the Go toolchain locally but requires
[docker](https://docs.docker.com/get-docker/).

1. Clone this repository and set it as the working directory:

```bash
$ git clone https://github.com/bazelbuild/bazel-toolchains.git
$ cd bazel-toolchains
```

2. Run the following command:

```bash
$ docker run --rm -v $PWD:/srcdir -w /srcdir golang:1.16 go build -o rbe_configs_gen ./cmd/rbe_configs_gen/rbe_configs_gen.go
```

3. Run `rbe_configs_gen` as follows to see the flags it accepts:

```
$ ./rbe_configs_gen --help
```

### Building Locally

1. Install [Go](https://golang.org/dl/) for your platform if necessary. Tested to work with Go 1.16.

2. Clone this repository

```bash
$ git clone https://github.com/bazelbuild/bazel-toolchains.git
$ cd bazel-toolchains
```

3. Build the rbe_configs_gen executable
```
# Use -o rbe_configs_gen.exe on Windows
$ go build -o rbe_configs_gen ./cmd/rbe_configs_gen/rbe_configs_gen.go
```

4. Run `rbe_configs_gen` as follows to see the flags it accepts:

```
# On Linux
$ ./rbe_configs_gen --help

# On Windows
$ rbe_configs_gen.exe
```


## Generating Configs

### Latest Bazel Version and Output Tarball

If you'd like to generate toolchain configs for the latest available Bazel release and the toolchain
container l.gcr.io/google/rbe-ubuntu16-04:latest and produce a tarball with the generated configs
run:

```bash
$ ./rbe_configs_gen \
    --toolchain_container=l.gcr.io/google/rbe-ubuntu16-04:latest \
    --output_tarball=rbe_default.tar \
    --exec_os=linux \
    --target_os=linux
```

The `exec_os` and `target_os` correspond to the Bazel
[execution & target platforms](https://docs.bazel.build/versions/master/platforms.html)
respectively.

You should see a tarball file `rbe_default.tar` locally containing the generated configs.

### Specific Bazel Version and Output Directory

If you'd like to generate toolchain configs for a specific Bazel release, e.g., Bazel 4.0.0 (tested
for versions >= 3.7.2) and the toolchain container l.gcr.io/google/rbe-ubuntu16-04:latest and
copy the generated configs to path `configs/path` relative to a source repository at
`/path/to/source/repo` run:

```bash
$ ./rbe_configs_gen \
    --bazel_version=4.0.0 \
    --toolchain_container=l.gcr.io/google/rbe-ubuntu16-04:latest \
    --output_src_root=/path/to/source/repo \
    --output_config_path=configs/path \
    --exec_os=linux \
    --target_os=linux
```

`/path/to/source/repo` should be the directory containing a Bazel `WORKSPACE` file. The toolchain
configs will be extracted to `/path/to/source/repo/configs/path`.

The `exec_os` and `target_os` correspond to the Bazel
[execution & target platforms](https://docs.bazel.build/versions/master/platforms.html)
respectively.

## Using Configs

### .bazelrc

Copy/import a `.bazelrc` file from [here](https://github.com/bazelbuild/bazel-toolchains/tree/master/bazelrc).
Pick the file that has the highest Bazel version in the filename that's less than or equal to the
Bazel version you're using.

### Option 1: Same Source Repository (Recommended)

If you [copied the generated configs](#specific-bazel-version-and-output-directory) to the source
repository where the rest of your code lives, and assuming the configs were copied to the path
`configs/path` (i.e., the value specified to the flag `--output_config_path` when running
`rbe_configs_gen`) relative to the directory containing the Bazel `WORKSPACE` file, all you need to
do is replace all occurences of `@rbe_default//` in your [`.bazelrc` file](#bazelrc) with `//configs/path`.

### Option 2: Remote Github Repository

If you extract the contents of a
[generated toolchain configs tarball](#specific-bazel-version-and-output-directory) into the root of
a Github repository e.g. `github.com/example/configs-repo` where this repository hosting the configs
is different from the source repository where you'd like to use the configs, include the following
in your `WORKSPACE`:

```python

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "rbe_default",
    # Replace this with the actual commit id of the Github repo you'd like to pin to.
    commit = "471da0273050b88d77529484ff89741ff586f9f5",
    remote = "https://github.com/example/configs-repo.git",
)

```

### Option 3: Remote Tarball Archive

Then, assuming you've upload the toolchain configs tarball to a remote location available at the
URL `https://example.com/rbe-default.tar`, include the following in your `WORKSPACE` file:

```python

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rbe_default",
    sha256 = "<replace this with the 64 character sha256 digest of the configs tarball>",
    urls = ["https://example.com/rbe-default.tar"],
)

```

### Custom Execution Properties

Certain remote execution backends support custom options such as selecting the VM machine type
remote actions run on, configuring certain docker properties if the remote actions are executed in
docker containers such as network access, privileged execution, allocated memory, etc. Bazel passes
on any property specified to the `exec_properties` attribute to a
[platform](https://docs.bazel.build/versions/master/be/platform.html#platform) definition to the
underlying remote execution system.

If you're using RBE, continue reading to see how to specify custom execution properties.

First, in your `WORKSPACE` file, import the latest commit of this repository (replace the commit ID
and sha256 digest with latest commit if necessary):

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
	name = "bazel_toolchains",
	urls = ["https://github.com/bazelbuild/bazel-toolchains/archive/dac71231098d891e5c4b74a2078fe9343feef510.tar.gz"],
	strip_prefix = "bazel-toolchains-dac71231098d891e5c4b74a2078fe9343feef510",
	sha256 = "56d5370eb99559b4c74f334f81bc8a298f728bd16d5a4333c865c2ad10fae3bc",
)

load("@bazel_toolchains//repositories:repositories.bzl", bazel_toolchains_repositories = "repositories")
bazel_toolchains_repositories()
```

Then declare a custom platform in a `BUILD` file. For now, let's assume this is the `BUILD` file at
the root of your source repository (i.e., the `BUILD` file & `WORKSPACE` file are in the same
directory):

```python

load("@bazel_toolchains//rules/exec_properties:exec_properties.bzl", "create_rbe_exec_properties_dict")

platform(
	name = "custom_platform",
    # Inherit from the platform target generated by 'rbe_configs_gen' assuming the generated configs
    # were imported as a Bazel external repository named 'rbe_default'. If you extracted the
    # generated configs elsewhere in your source repository, replace the following with the label
    # to the 'platform' target in the generated configs.
	parents = ["@rbe_default//config:platform"],
    # Example custom execution property instructing RBE to use e2-standard-2 GCE VMs.
	exec_properties = create_rbe_exec_properties_dict(
		gce_machine_type = "e2-standard-2",
	),
)

```

See [here](https://github.com/bazelbuild/bazel-toolchains/blob/dac71231098d891e5c4b74a2078fe9343feef510/rules/exec_properties/exec_properties.bzl#L143)
for a list of parameters accepted by `create_rbe_exec_properties_dict`.

Finally, in your `.bazelrc` file, replace all options specifying a platform target with
the above custom platform target instead. So for example, if your `.bazelrc` previously looked like

```bash
...
build:remote --extra_execution_platforms=@rbe_default//config:platform
build:remote --host_platform=@rbe_default//config:platform
build:remote --platforms=@rbe_default//config:platform
...
```

It should now look like

```bash
build:remote --extra_execution_platforms=//:custom_platform
build:remote --host_platform=//:custom_platform
build:remote --platforms=//:custom_platform
```

# Pre-generated Configs

Pre-generated configs tarballs will be generated for every Bazel release starting with 4.0.0 & the
latest available [Ubuntu 16.04 Clang + JDK](https://l.gcr.io/google/rbe-ubuntu16-04:latest) container and
uploaded to GCS.

**IMPORTANT**: Ensure you read & agree with the terms of the `LICENSE` file included in the
configs tarball before using pre-generated configs.

Basically, never depend directly on any of the URLs mentioned below to download toolchain configs in
production because they may break without warning. Pre-generated configs are only provided as a
convenience for experimenting with configuring Bazel for remote builds. Further, there are no
guarantees on how long after a new release of Bazel or the Ubuntu 16.04 container mentioned above
the corresponding pre-generated configs will be available. It's strongly recommended to generate and
host your own toolchain configs by running the `rbe_config_gen` tool and test the functionality and
correctness of the configs yourself before using them in production. Alternatively, you could also
copy pre-generated configs and host it in a location you control after verifying correctness before
using them in production.

See [here](#bazelrc) for instructions on how to initialize your `.bazelrc` file.

## Latest Bazel and Latest Ubuntu 16.04 Container

1. Examine the contents of the JSON manifest of the latest configs.

```bash
$ curl https://storage.googleapis.com/rbe-toolchain/bazel-configs/rbe-ubuntu1604/latest/manifest.json
{
 "bazel_version": "4.0.0",
 "toolchain_container": "l.gcr.io/google/rbe-ubuntu16-04:latest",
 "image_digest": "f6568d8168b14aafd1b707019927a63c2d37113a03bcee188218f99bd0327ea1",
 "exec_os": "Linux",
 "configs_tarball_digest": "c0d428774cbe70d477e1d07581d863f8dbff4ba6a66d20502d7118354a814bea",
 "upload_time": "2021-02-18T06:02:32.997892223-08:00"
}
```

1. The manifest indicates the configs are for Bazel 4.0.0, generated for the container
   `l.gcr.io/google/rbe-ubuntu16-04@sha256:f6568d8168b14aafd1b707019927a63c2d37113a03bcee188218f99bd0327ea1`
   and the sha256 digest of the uploaded configs tarball is `c0d428774cbe70d477e1d07581d863f8dbff4ba6a66d20502d7118354a814bea`.
   To use these configs, add the following to your Bazel `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rbe_default",
    # Change the sha256 digest to the value of the `configs_tarball_digest` in the manifest you
    # got when you ran the curl command above.
    sha256 = "c0d428774cbe70d477e1d07581d863f8dbff4ba6a66d20502d7118354a814bea",
    urls = ["https://storage.googleapis.com/rbe-toolchain/bazel-configs/rbe-ubuntu1604/latest/rbe_default.tar"],
)
```

## Specific Bazel and Latest Ubuntu 16.04 Container

1. Say you'd like to use configs for Bazel 4.0.0 specifically.

1. Check if a manifest exists for the Bazel version you're interested in (version should be >=
   4.0.0).

```bash
# Replace "bazel_4.0.0" in the URL below with whatever "bazel_<version>" you'd like to you.
$ curl https://storage.googleapis.com/rbe-toolchain/bazel-configs/bazel_4.0.0/rbe-ubuntu1604/latest/manifest.json
{
 "bazel_version": "4.0.0",
 "toolchain_container": "l.gcr.io/google/rbe-ubuntu16-04:latest",
 "image_digest": "f6568d8168b14aafd1b707019927a63c2d37113a03bcee188218f99bd0327ea1",
 "exec_os": "Linux",
 "configs_tarball_digest": "c0d428774cbe70d477e1d07581d863f8dbff4ba6a66d20502d7118354a814bea",
 "upload_time": "2021-02-18T06:02:32.997892223-08:00"
}
```

1. The manifest confirms the configs are for Bazel 4.0.0, generated for the container
   `l.gcr.io/google/rbe-ubuntu16-04@sha256:f6568d8168b14aafd1b707019927a63c2d37113a03bcee188218f99bd0327ea1`
   and the sha256 digest of the uploaded configs tarball is `c0d428774cbe70d477e1d07581d863f8dbff4ba6a66d20502d7118354a814bea`.
   To use these configs, add the following to your Bazel `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rbe_default",
    # Change the sha256 digest to the value of the `configs_tarball_digest` in the manifest you
    # got when you ran the curl command above.
    sha256 = "c0d428774cbe70d477e1d07581d863f8dbff4ba6a66d20502d7118354a814bea",
    # Change "bazel_4.0.0" in the URL below with whatever "bazel_<version>" you downloaded the
    # manifest for in the previous step.
    urls = ["https://storage.googleapis.com/rbe-toolchain/bazel-configs/bazel_4.0.0/rbe-ubuntu1604/latest/rbe_default.tar"],
)
```

# Where is rbe_autoconfig?

The [rbe_autoconfig](https://github.com/bazelbuild/bazel-toolchains/blob/4.0.0/rules/rbe_repo.bzl#L896)
Bazel repository rule used to generate & use toolchain configs has been deprecated with release
[v4.0.0](https://github.com/bazelbuild/bazel-toolchains/releases/tag/4.0.0) of this repository
being the last release that supports rbe_autoconfig. Release v4.0.0 supports Bazel versions up to
[4.0.0](https://github.com/bazelbuild/bazel/releases/tag/4.0.0).
