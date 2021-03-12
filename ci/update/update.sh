#!/bin/sh

#	update -- update master to latest release tag

set -ex

target_version="$(cat $1)"
release_branch="$2"

cd master

git checkout master
git remote add -f --tags -t "$release_branch" release ../release

git config --global user.email "ranger6@users.noreply.github.com"
git config --global user.name "ranger6"

git merge --ff-only "$target_version" 
