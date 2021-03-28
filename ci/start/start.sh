#!/bin/sh

#       start -- when triggered, start new release branch
#                put release branch name in vars.json

set -ex

target_version="$(cat $1)"
branch_hash="$2"
release_branch_prefix="$3"

release_branch="${release_branch_prefix}${target_version}"

echo "{\"release-branch-name\": \"${release_branch}\"}" > release-vars/vars.json

cd main

git config --global user.email "ranger6@users.noreply.github.com"
git config --global user.name "ranger6"

git checkout -b "$release_branch" "$branch_hash"

#	this is a placeholder action for what might need
#	to be done when preparing a new release.

echo $target_version > version.txt

git add .
git commit -m "starting new release branch \"$release_branch\" for target version \"$target_version\""
