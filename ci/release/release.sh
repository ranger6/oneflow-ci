#!/bin/sh

#       release -- tag the HEAD of the release branch with
#                  target version, merge back into the main branch

set -ex

target_version="$(cat $1)"
release_branch="$2"
main_branch="$3"
git_user_name="$4"
git_user_email="$5"

# git checkout "$release_branch"
# git tag -a -m "tagging release at $target_version" "$target_version"
echo "$target_version" > tags/name
echo "tagging release at $target_version" > tags/annotation

cd main

git config --global user.name "$git_user_name"
git config --global user.email "$git_user_email"

git checkout $main_branch
git pull --no-edit --no-rebase ../release "$release_branch"
