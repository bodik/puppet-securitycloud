#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA

cd $BUILD_AREA || exit 1
VER=1.16
wget http://libnf.net/packages/libnf-${VER}.tar.gz
tar xzf libnf-${VER}.tar.gz
cd libnf-${VER} 
./configure
make
mkdir ${BUILD_AREA}/libnf-install
make DESTDIR="${BUILD_AREA}/libnf-install" install
make DESTDIR="${BUILD_AREA}/compact-install" install
cd ..
for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/libnf-install" --name libnf --version ${VER} --iteration 1  \
		--after-install /puppet/fdistdump/files/libnf.postinst --after-remove /puppet/fdistdump/files/libnf.postrm \
		--description "libnf package from libnf.net/packages" --maintainer "bodik@cesnet.cz" --vendor "" --url "http://libnf.net"
done
dpkg -i libnf_${VER}-1_$(dpkg --print-architecture).deb

