#!/bin/sh

#       merge -- merge release branch back into the main branch
#		 The magic merge happens with the "pull" from a repo with
#		 the release branch cloned (../release) to the repo with
#		 the main branch checked out.

set -ex

release_branch="$1"
main_branch="$2"
git_user_name="$3"
git_user_email="$4"

cd main

git config --global user.name "$git_user_name"
git config --global user.email "$git_user_email"

git checkout $main_branch
git pull --no-edit --no-rebase ../release "$release_branch"
