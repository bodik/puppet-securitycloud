#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA

cd $BUILD_AREA || exit 1
VER=0.1

git clone https://github.com/CESNET/ipfixcol
cd ipfixcol || exit 1
autoreconf -i
./configure
make
mkdir ${BUILD_AREA}/ipfixcol-install
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install
cd ..
for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/ipfixcol-install" --name ipfixcol --version ${VER} --iteration 1  \
		--description "fdistdump from https://github.com/CESNET/ipfixcol" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"
done
dpkg -i ipfixcol_${VER}-1_$(dpkg --print-architecture).deb

