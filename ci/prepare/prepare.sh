#!/bin/sh

#	prepare -- prepare a pre-release
#                  $1 is tag annotation

set -ex

(echo -n "tagging " ; cat "$1") > prerel/tag_annotation
