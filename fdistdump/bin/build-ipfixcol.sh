#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA

cd $BUILD_AREA || exit 1
VER=0.1

if [ ! -d ipfixcol ]; then
	git clone https://github.com/CESNET/ipfixcol
fi

cd ipfixcol/base || exit 1
autoreconf -i
./configure
make
mkdir ${BUILD_AREA}/ipfixcol-base-install
make DESTDIR="${BUILD_AREA}/ipfixcol-base-install" install
cd $BUILD_AREA || exit 1
for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/ipfixcol-base-install" --name ipfixcol-base --version ${VER} --iteration 1  \
		--depends libxml2 \
		--description "ipfixcol-base from https://github.com/CESNET/ipfixcol" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"
done
dpkg -i ipfixcol-base_${VER}-1_$(dpkg --print-architecture).deb


##--depends libxml2 --depends openssl --depends libsctp1 --depends libbz2 --depends libpq5 --depends libgeoip1 --depends librrd4 --depends libsqlite3-0 \

