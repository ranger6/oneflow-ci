#!/bin/sh

#       content -- add whatever content is needed to new release branch

set -ex

target_version="$(cat $1)"
release_branch="$2"
git_user_name="$3"
git_user_email="$4"

cd main

git config --global user.name "$git_user_name"
git config --global user.email "$git_user_email"

git checkout "$release_branch"

echo $target_version > version.txt
git add .
git commit -m "updating version info to $target_version"
