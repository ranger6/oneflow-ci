#!/bin/sh

#	clean -- clean up after release, delete release branch

set -ex

target_version="$(cat $1)"
release_branch="$2"

cd release

git checkout $target_version

git config --global user.email "ranger6@users.noreply.github.com"
git config --global user.name "ranger6"

git branch -D "$release_branch"
