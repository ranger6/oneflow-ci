#!/bin/sh

#       prepare -- tag the HEAD of the release branch with
#                  pre-release version, merge back in the put step

set -ex

target_version="$(cat $1)"

echo "$target_version" > tags/name
echo "tagging pre-release at $target_version" > tags/annotation
