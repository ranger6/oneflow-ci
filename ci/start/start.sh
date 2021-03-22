#!/bin/sh

#       start -- when triggered, start new release branch

set -ex

target_version="$(cat $1)"
branch_hash="$2"
release_branch_prefix="$3"

release_branch="${release_branch_prefix}${target_version}"

echo "{\"release-branch-name\": \"${release_branch}\"}" > release-branch/vars.json

git clone main release
cd release
git checkout -b "$release_branch" "$branch_hash"

git config --global user.email "ranger6@users.noreply.github.com"
git config --global user.name "ranger6"

echo $target_version > version.txt

git add .
git commit -m "set target version $target_version on $release_branch"
