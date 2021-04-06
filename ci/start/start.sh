#!/bin/sh

#       start -- when triggered, start new release branch
#                put release branch name in vars.json so that it can be load_var'ed

set -ex

target_version="$(cat $1)"
branch_hash="$2"
release_branch_prefix="$3"

release_branch="${release_branch_prefix}${target_version}"
echo "{\"release-branch-name\": \"${release_branch}\"}" > release-vars/vars.json

cd main

git checkout -b "$release_branch" "$branch_hash"
