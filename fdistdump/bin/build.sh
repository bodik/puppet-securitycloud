#!/bin/sh
set -e

git config --global user.name "bodik"
git config --global user.email "bodik@cesnet.cz"
#git commit --amend --author="Radoslav Bodo <bodik@cesnet.cz>"

BUILD_AREA=/tmp/build_area
rm -r ${BUILD_AREA} || true
dpkg --purge libnf fdistdump 2>/dev/null
mkdir -p $BUILD_AREA
mkdir -p $BUILD_AREA/compact-install

sh /puppet/fdistdump/bin/build-libnf.sh
sh /puppet/fdistdump/bin/build-fdistdump.sh
sh /puppet/fdistdump/bin/build-puppet-fdistdump.sh
sh /puppet/fdistdump/bin/build-compact.sh

