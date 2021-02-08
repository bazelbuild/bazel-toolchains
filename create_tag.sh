#!/bin/bash
set -eux

version=v5.0.0

echo "Checkout out the master branch"
git checkout master

# The following command may fail if:
# 1. The tag already exists. If the tag was previously pushed and released,
#    just increment 'version' above to create a new tag. If the tag was
#    created locally but wasn't pushed to Github, run `git tag -d $version`.
# 2. git isn't configured to use a GPG signing key. For this see
#    https://docs.github.com/en/github/authenticating-to-github/telling-git-about-your-signing-key
echo "Tagging the master branch as $version signed with a GPG key."
git tag -s $version

# If the following command fails complaining about there being no upstream just
# run 'git remote add upstream git@github.com:bazelbuild/bazel-toolchains.git'.
echo "Pushing new tags to remote."
# TODO: Actually use upstream instead of origin.
git push origin $version

echo "Successfully created tag $version"
