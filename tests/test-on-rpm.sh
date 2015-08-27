#!/usr/bin/env bash
SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"


yum -y install epel-release
yum -y update
set -e
echo "Run build static version"
$RDIR/../build_static.sh -d yes