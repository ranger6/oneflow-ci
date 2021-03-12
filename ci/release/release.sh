#!/bin/sh

#       release -- tag the HEAD of the release branch with
#                  target version, merge back in the put step

set -ex

target_version="$(cat $1)"
release_branch="$2"
merge_branch="$3"

cd release

git checkout "$release_branch"

git config --global user.email "ranger6@users.noreply.github.com"
git config --global user.name "ranger6"

git tag -a -m "tagging release at $target_version" "$target_version"
