#!/bin/sh

#       release -- tag the HEAD of the release branch with
#                  target version, merge back into the main branch

set -ex

target_version="$(cat $1)"
release_branch="$2"
main_branch="$3"

cd release

git config --global user.email "ranger6@users.noreply.github.com"
git config --global user.name "ranger6"

git checkout "$release_branch"
git tag -a -m "tagging release at $target_version" "$target_version"

cd ../main

git checkout $main_branch
git pull --no-edit --no-rebase ../release "$release_branch"
