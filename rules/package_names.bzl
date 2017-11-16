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
"""package_names.bzl contains definitions of functions that return lists of package names.

This includes all package names for a given distro (i.e., def
<distro>_package_names) as well as private defs defining all packages for a
given tool (a tool requires several packages to be installed). This file also
contains a struct with the names of all tools. Lastly, this file defines a map
from tools to package names for each distro (i.e., def <distro>_tools()).
"""


def jessie_package_names():
  packages = []
  for key in jessie_tools():
    packages.extend(jessie_tools()[key])
  return depset(packages).to_list()


def trusty_package_names():
  packages = []
  for key in trusty_tools():
    packages.extend(trusty_tools()[key])
  return depset(packages).to_list()


def xenial_package_names():
  packages = []
  for key in xenial_tools():
    packages.extend(xenial_tools()[key])
  return depset(packages).to_list()


tool_names = struct(
    bazel="bazel",
    curl="curl",
    gcc="gcc",
    git="git",
    java="java",
    python_dev="python_dev",
    wget="wget",
    zip="zip",
)


def jessie_tools():
  return {
      tool_names.curl: _jessie_curl_package_names(),
      tool_names.gcc: _jessie_gcc_package_names(),
      tool_names.git: _jessie_git_package_names(),
      tool_names.java: _jessie_java_package_names(),
      tool_names.python_dev: _jessie_python_dev_package_names(),
      tool_names.wget: _jessie_wget_package_names(),
      tool_names.zip: _zip_package_names(),
  }


def trusty_tools():
  return {
      tool_names.curl: _trusty_curl_package_names(),
      tool_names.gcc: _trusty_gcc_package_names(),
      tool_names.git: _trusty_git_package_names(),
      tool_names.java: _trusty_java_package_names(),
      tool_names.python_dev: _trusty_python_dev_package_names(),
      tool_names.wget: _trusty_wget_package_names(),
      tool_names.zip: _zip_package_names(),
  }


def xenial_tools():
  return {
      tool_names.curl: _xenial_curl_package_names(),
      tool_names.gcc: _xenial_gcc_package_names(),
      tool_names.git: _xenial_git_package_names(),
      tool_names.java: _xenial_java_package_names(),
      tool_names.python_dev: _xenial_python_dev_package_names(),
      tool_names.wget: _xenial_wget_package_names(),
      tool_names.zip: _zip_package_names(),
  }


def _jessie_curl_package_names():
  return [
      "curl",
      "libcurl3",
      "libffi6",
      "libgmp10",
      "libgnutls-deb0-28",
      "libgssapi-krb5-2",
      "libhogweed2",
      "libidn11",
      "libk5crypto3",
      "libkeyutils1",
      "libkrb5-3",
      "libkrb5support0",
      "libldap-2.4-2",
      "libnettle4",
      "libp11-kit0",
      "librtmp1",
      "libsasl2-2",
      "libsasl2-modules-db",
      "libssh2-1",
      "libtasn1-6",
  ]


def _jessie_gcc_package_names():
  return [
      "binutils",
      "cpp",
      "cpp-4.9",
      "g++",
      "g++-4.9",
      "gcc",
      "gcc-4.9",
      "libasan1",
      "libatomic1",
      "libc-dev-bin",
      "libc6-dev",
      "libcilkrts5",
      "libcloog-isl4",
      "libgcc-4.9-dev",
      "libgmp10",
      "libgomp1",
      "libisl10",
      "libitm1",
      "liblsan0",
      "libmpc3",
      "libmpfr4",
      "libquadmath0",
      "libstdc++-4.9-dev",
      "libtsan0",
      "libubsan0",
      "linux-libc-dev",
  ]


def _jessie_git_package_names():
  return [
      "git",
      "git-man",
      "libcurl3-gnutls",
      "liberror-perl",
      "libexpat1",
      "libffi6",
      "libgdbm3",
      "libgmp10",
      "libgnutls-deb0-28",
      "libgssapi-krb5-2",
      "libhogweed2",
      "libidn11",
      "libk5crypto3",
      "libkeyutils1",
      "libkrb5-3",
      "libkrb5support0",
      "libldap-2.4-2",
      "libnettle4",
      "libp11-kit0",
      "librtmp1",
      "libsasl2-2",
      "libsasl2-modules-db",
      "libssh2-1",
      "libtasn1-6",
      "perl",
      "perl-modules",
      # Though not strictly required, we get a 'Problem with the SSL CA cert'
      # errror w/o these packages
      "ca-certificates",
      "libssl1.0.0",
      "openssl",
  ]


def _jessie_java_package_names():
  return [
      "ca-certificates-java",
      "fontconfig-config",
      "fonts-dejavu-core",
      "java-common",
      "libavahi-client3",
      "libavahi-common-data",
      "libavahi-common3",
      "libcups2",
      "libdbus-1-3",
      "libexpat1",
      "libffi6",
      "libfontconfig1",
      "libfreetype6",
      "libgmp10",
      "libgnutls-deb0-28",
      "libgssapi-krb5-2",
      "libhogweed2",
      "libjpeg62-turbo",
      "libk5crypto3",
      "libkeyutils1",
      "libkrb5-3",
      "libkrb5support0",
      "liblcms2-2",
      "libnettle4",
      "libnspr4",
      "libnss3",
      "libp11-kit0",
      "libpcsclite1",
      "libpng12-0",
      "libsqlite3-0",
      "libtasn1-6",
      "libx11-6",
      "libx11-data",
      "libxau6",
      "libxcb1",
      "libxdmcp6",
      "libxext6",
      "libxi6",
      "libxrender1",
      "libxtst6",
      "openjdk-8-jdk-headless",
      "openjdk-8-jre-headless",
      "ucf",
      "x11-common",
      "zlib1g",
  ]


def _jessie_python_dev_package_names():
  return [
      "libc-dev-bin",
      "libc6-dev",
      "libexpat1",
      "libexpat1-dev",
      "libffi6",
      "libpython-dev",
      "libpython-stdlib",
      "libpython2.7",
      "libpython2.7-dev",
      "libpython2.7-minimal",
      "libpython2.7-stdlib",
      "libsqlite3-0",
      "linux-libc-dev",
      "mime-support",
      "python",
      "python-dev",
      "python-minimal",
      "python2.7",
      "python2.7-dev",
      "python2.7-minimal",
  ]


def _jessie_wget_package_names():
  return [
      "libffi6",
      "libgmp10",
      "libgnutls-deb0-28",
      "libhogweed2",
      "libicu52",
      "libidn11",
      "libnettle4",
      "libp11-kit0",
      "libpsl0",
      "libtasn1-6",
      "wget",
      # Needed for cert validation done by wget
      "ca-certificates",
      "libssl1.0.0",
      "openssl",
  ]


def _trusty_curl_package_names():
  return [
      "curl",
      "libasn1-8-heimdal",
      "libcurl3",
      "libgssapi-krb5-2",
      "libgssapi3-heimdal",
      "libhcrypto4-heimdal",
      "libheimbase1-heimdal",
      "libheimntlm0-heimdal",
      "libhx509-5-heimdal",
      "libidn11",
      "libk5crypto3",
      "libkeyutils1",
      "libkrb5-26-heimdal",
      "libkrb5-3",
      "libkrb5support0",
      "libldap-2.4-2",
      "libroken18-heimdal",
      "librtmp0",
      "libsasl2-2",
      "libsasl2-modules-db",
      "libwind0-heimdal",
  ]


def _trusty_gcc_package_names():
  return [
      "binutils",
      "cpp",
      "cpp-4.8",
      "g++",
      "g++-4.8",
      "gcc",
      "gcc-4.8",
      "libasan0",
      "libatomic1",
      "libc-dev-bin",
      "libc6-dev",
      "libcloog-isl4",
      "libgcc-4.8-dev",
      "libgmp10",
      "libgomp1",
      "libisl10",
      "libitm1",
      "libmpc3",
      "libmpfr4",
      "libquadmath0",
      "libstdc++-4.8-dev",
      "libtsan0",
      "linux-libc-dev",
  ]


def _trusty_git_package_names():
  return [
      "git",
      "git-man",
      "libasn1-8-heimdal",
      "libcurl3-gnutls",
      "liberror-perl",
      "libgssapi-krb5-2",
      "libgssapi3-heimdal",
      "libhcrypto4-heimdal",
      "libheimbase1-heimdal",
      "libheimntlm0-heimdal",
      "libhx509-5-heimdal",
      "libidn11",
      "libk5crypto3",
      "libkeyutils1",
      "libkrb5-26-heimdal",
      "libkrb5-3",
      "libkrb5support0",
      "libldap-2.4-2",
      "libroken18-heimdal",
      "librtmp0",
      "libsasl2-2",
      "libsasl2-modules-db",
      "libwind0-heimdal",
      # Though not strictly required, we get a 'Problem with the SSL CA cert'
      # errror w/o these packages
      "ca-certificates",
      "openssl",
  ]


def _trusty_java_package_names():
  return [
      "ca-certificates-java",
      "fontconfig",
      "fontconfig-config",
      "fonts-dejavu-core",
      "java-common",
      "libasound2",
      "libasound2-data",
      "libasyncns0",
      "libatk-wrapper-java",
      "libatk-wrapper-java-jni",
      "libatk1.0-0",
      "libatk1.0-data",
      "libavahi-client3",
      "libavahi-common-data",
      "libavahi-common3",
      "libcairo2",
      "libcups2",
      "libdatrie1",
      "libflac8",
      "libfontconfig1",
      "libfreetype6",
      "libgdk-pixbuf2.0-0",
      "libgdk-pixbuf2.0-common",
      "libgif4",
      "libgl1-mesa-glx",
      "libglapi-mesa",
      "libgraphite2-3",
      "libgtk2.0-0",
      "libgtk2.0-common",
      "libharfbuzz0b",
      "libjasper1",
      "libjbig0",
      "libjpeg-turbo8",
      "libjpeg8",
      "liblcms2-2",
      "libnspr4",
      "libnss3",
      "libnss3-nssdb",
      "libogg0",
      "libpango-1.0-0",
      "libpangocairo-1.0-0",
      "libpangoft2-1.0-0",
      "libpcsclite1",
      "libpixman-1-0",
      "libpulse0",
      "libsctp1",
      "libsndfile1",
      "libthai-data",
      "libthai0",
      "libtiff5",
      "libvorbis0a",
      "libvorbisenc2",
      "libwrap0",
      "libx11-6",
      "libx11-data",
      "libx11-xcb1",
      "libxau6",
      "libxcb-dri2-0",
      "libxcb-dri3-0",
      "libxcb-glx0",
      "libxcb-present0",
      "libxcb-render0",
      "libxcb-shm0",
      "libxcb-sync1",
      "libxcb1",
      "libxcomposite1",
      "libxcursor1",
      "libxdamage1",
      "libxdmcp6",
      "libxext6",
      "libxfixes3",
      "libxi6",
      "libxinerama1",
      "libxrandr2",
      "libxrender1",
      "libxshmfence1",
      "libxtst6",
      "libxxf86vm1",
      "openjdk-8-jdk",
      "openjdk-8-jdk-headless",
      "openjdk-8-jre",
      "openjdk-8-jre-headless",
      "tzdata-java",
      "x11-common",
  ]


def _trusty_python_dev_package_names():
  return [
      "libc-dev-bin",
      "libc6-dev",
      "libexpat1-dev",
      "libpython-dev",
      "libpython-stdlib",
      "libpython2.7",
      "libpython2.7-dev",
      "libpython2.7-minimal",
      "libpython2.7-stdlib",
      "linux-libc-dev",
      "python",
      "python-dev",
      "python-minimal",
      "python2.7",
      "python2.7-dev",
      "python2.7-minimal",
  ]


def _trusty_wget_package_names():
  return [
      "wget",
      "libidn11",
      "zlib1g",
      # Needed for cert validation done by wget
      "ca-certificates",
      "openssl",
  ]


def _xenial_curl_package_names():
  return [
      "curl",
      "libasn1-8-heimdal",
      "libcurl3-gnutls",
      "libffi6",
      "libgmp10",
      "libgnutls30",
      "libgssapi-krb5-2",
      "libgssapi3-heimdal",
      "libhcrypto4-heimdal",
      "libheimbase1-heimdal",
      "libheimntlm0-heimdal",
      "libhogweed4",
      "libhx509-5-heimdal",
      "libidn11",
      "libk5crypto3",
      "libkeyutils1",
      "libkrb5-26-heimdal",
      "libkrb5-3",
      "libkrb5support0",
      "libldap-2.4-2",
      "libnettle6",
      "libp11-kit0",
      "libroken18-heimdal",
      "librtmp1",
      "libsasl2-2",
      "libsasl2-modules-db",
      "libsqlite3-0",
      "libtasn1-6",
      "libwind0-heimdal",
  ]


def _xenial_gcc_package_names():
  return [
      "binutils",
      "cpp",
      "cpp-5",
      "g++",
      "g++-5",
      "gcc",
      "gcc-5",
      "libasan2",
      "libatomic1",
      "libc-dev-bin",
      "libc6-dev",
      "libcc1-0",
      "libcilkrts5",
      "libgcc-5-dev",
      "libgmp10",
      "libgomp1",
      "libisl15",
      "libitm1",
      "liblsan0",
      "libmpc3",
      "libmpfr4",
      "libmpx0",
      "libquadmath0",
      "libstdc++-5-dev",
      "libtsan0",
      "libubsan0",
      "linux-libc-dev",
  ]


def _xenial_git_package_names():
  return [
      "git",
      "git-man",
      "libasn1-8-heimdal",
      "libcurl3-gnutls",
      "liberror-perl",
      "libexpat1",
      "libffi6",
      "libgdbm3",
      "libgmp10",
      "libgnutls30",
      "libgssapi-krb5-2",
      "libgssapi3-heimdal",
      "libhcrypto4-heimdal",
      "libheimbase1-heimdal",
      "libheimntlm0-heimdal",
      "libhogweed4",
      "libhx509-5-heimdal",
      "libidn11",
      "libk5crypto3",
      "libkeyutils1",
      "libkrb5-26-heimdal",
      "libkrb5-3",
      "libkrb5support0",
      "libldap-2.4-2",
      "libnettle6",
      "libp11-kit0",
      "libperl5.22",
      "libroken18-heimdal",
      "librtmp1",
      "libsasl2-2",
      "libsasl2-modules-db",
      "libsqlite3-0",
      "libtasn1-6",
      "libwind0-heimdal",
      "perl",
      "perl-modules-5.22",
      # Though not strictly required, we get a 'Problem with the SSL CA cert'
      # errror w/o these packages
      "ca-certificates",
      "libssl1.0.0",
      "openssl",
  ]


def _xenial_java_package_names():
  return [
      "ca-certificates",
      "ca-certificates-java",
      "fontconfig",
      "fontconfig-config",
      "fonts-dejavu-core",
      "java-common",
      "libasound2",
      "libasound2-data",
      "libasyncns0",
      "libatk1.0-0",
      "libatk1.0-data",
      "libavahi-client3",
      "libavahi-common-data",
      "libavahi-common3",
      "libbsd0",
      "libcairo2",
      "libcups2",
      "libdatrie1",
      "libdbus-1-3",
      "libdrm-amdgpu1",
      "libdrm-intel1",
      "libdrm-nouveau2",
      "libdrm-radeon1",
      "libdrm2",
      "libedit2",
      "libelf1",
      "libexpat1",
      "libffi6",
      "libflac8",
      "libfontconfig1",
      "libfreetype6",
      "libgdk-pixbuf2.0-0",
      "libgdk-pixbuf2.0-common",
      "libgif7",
      "libgl1-mesa-dri",
      "libgl1-mesa-glx",
      "libglapi-mesa",
      "libglib2.0-0",
      "libgmp10",
      "libgnutls30",
      "libgraphite2-3",
      "libgssapi-krb5-2",
      "libgtk2.0-0",
      "libgtk2.0-common",
      "libharfbuzz0b",
      "libhogweed4",
      "libicu55",
      "libidn11",
      "libjbig0",
      "libjpeg-turbo8",
      "libjpeg8",
      "libjson-c2",
      "libk5crypto3",
      "libkeyutils1",
      "libkrb5-3",
      "libkrb5support0",
      "liblcms2-2",
      "libllvm3.8",
      "libnettle6",
      "libnspr4",
      "libnss3",
      "libnss3-nssdb",
      "libogg0",
      "libp11-kit0",
      "libpango-1.0-0",
      "libpangocairo-1.0-0",
      "libpangoft2-1.0-0",
      "libpciaccess0",
      "libpcsclite1",
      "libpixman-1-0",
      "libpng12-0",
      "libpulse0",
      "libsensors4",
      "libsndfile1",
      "libsqlite3-0",
      "libssl1.0.0",
      "libtasn1-6",
      "libthai-data",
      "libthai0",
      "libtiff5",
      "libvorbis0a",
      "libvorbisenc2",
      "libwrap0",
      "libx11-6",
      "libx11-data",
      "libx11-xcb1",
      "libxau6",
      "libxcb-dri2-0",
      "libxcb-dri3-0",
      "libxcb-glx0",
      "libxcb-present0",
      "libxcb-render0",
      "libxcb-shm0",
      "libxcb-sync1",
      "libxcb1",
      "libxcomposite1",
      "libxcursor1",
      "libxdamage1",
      "libxdmcp6",
      "libxext6",
      "libxfixes3",
      "libxi6",
      "libxinerama1",
      "libxml2",
      "libxrandr2",
      "libxrender1",
      "libxshmfence1",
      "libxtst6",
      "libxxf86vm1",
      "openjdk-8-jdk",
      "openjdk-8-jdk-headless",
      "openjdk-8-jre",
      "openjdk-8-jre-headless",
      "openssl",
      "shared-mime-info",
      "ucf",
      "x11-common",
  ]


def _xenial_python_dev_package_names():
  return [
      "libc-dev-bin",
      "libc6-dev",
      "libexpat1",
      "libexpat1-dev",
      "libffi6",
      "libpython-dev",
      "libpython-stdlib",
      "libpython2.7",
      "libpython2.7-dev",
      "libpython2.7-minimal",
      "libpython2.7-stdlib",
      "libsqlite3-0",
      "libssl1.0.0",
      "linux-libc-dev",
      "mime-support",
      "python",
      "python-dev",
      "python-minimal",
      "python2.7",
      "python2.7-dev",
      "python2.7-minimal",
  ]


def _xenial_wget_package_names():
  return [
      "libidn11",
      "libssl1.0.0",
      "wget",
      # Needed for cert validation done by wget
      "ca-certificates",
      "libssl1.0.0",
      "openssl",
  ]


def _zip_package_names():
  return [
      "zip",
      "unzip",
  ]
