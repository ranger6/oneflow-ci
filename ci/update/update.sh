#!/bin/sh

#	update -- update stable branch to latest release tag

set -ex

target_version="$(cat $1)"
release_branch="$2"
stable_branch="$3"
git_user_name="$4"
git_user_email="$5"

cd stable

git config --global user.name "$git-user-name"
git config --global user.email "$git-user-name"

git checkout $stable_branch
git remote add -f --tags -t "$release_branch" release ../release

git merge --ff-only "$target_version" 
