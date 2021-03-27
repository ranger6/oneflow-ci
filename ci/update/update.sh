#!/bin/sh

#	update -- update stable branch to latest release tag

set -ex

target_version="$(cat $1)"
release_branch="$2"
stable_branch="$3"

cd stable

git config --global user.email "ranger6@users.noreply.github.com"
git config --global user.name "ranger6"

git checkout $stable_branch
git remote add -f --tags -t "$release_branch" release ../release

git merge --ff-only "$target_version" 
