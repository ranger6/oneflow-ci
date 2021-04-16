#!/bin/sh

#       content -- add whatever content is needed to new release branch

set -ex

target_version="$(cat $1)"
release_branch="$2"

cd main

git checkout "$release_branch"

echo $target_version > version.txt
git add .
git commit -m "updating version info to $target_version"
