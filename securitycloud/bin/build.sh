#!/bin/sh
set -e

git config --global user.name "bodik"
git config --global user.email "bodik@cesnet.cz"
#git commit --amend --author="Radoslav Bodo <bodik@cesnet.cz>"

BUILD_AREA=/tmp/build_area
rm -r ${BUILD_AREA} || true
dpkg --purge libnf fdistdump ipfixcol ipfixcol-buildstub 2>/dev/null
mkdir -p $BUILD_AREA

sh /puppet/securitycloud/bin/build-libnf.sh
sh /puppet/securitycloud/bin/build-fdistdump.sh
sh /puppet/securitycloud/bin/build-ipfixcol.sh

