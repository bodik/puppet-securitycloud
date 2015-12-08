#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA

cd $BUILD_AREA || exit 1
VER=0.2

git clone https://github.com/CESNET/libfastbit
cd libfastbit || exit 1
autoreconf -i
./configure
make

mkdir ${BUILD_AREA}/libfastbit-install
make DESTDIR="${BUILD_AREA}/libfastbit-install" install
cd ..
for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/libfastbit-install" --name libfastbit --version ${VER} --iteration 1  \
		--description "libfastbit from https://github.com/CESNET/libfastbit" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/libfastbit"
done
dpkg -i libfastbit_${VER}-1_$(dpkg --print-architecture).deb


