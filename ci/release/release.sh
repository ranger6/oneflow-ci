#!/bin/sh

#       release -- create tag info for the release branch with
#                  target version

set -ex

target_version="$(cat $1)"

echo "$target_version" > tags/name
echo "tagging release at $target_version" > tags/annotation
