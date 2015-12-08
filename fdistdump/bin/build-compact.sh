#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA

cd $BUILD_AREA || exit 1
VER=0.1
fpm -s dir -t tar -C "${BUILD_AREA}/compact-install/" --name fdistdump-${VER}-1 
