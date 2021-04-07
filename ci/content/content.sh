#!/bin/sh

#       content -- add whatever content is needed to new release branch

set -ex

target_version="$(cat $1)"
release_branch="$2"

cd main

git checkout -b "$release_branch" "$branch_hash"
