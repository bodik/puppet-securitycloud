#!/bin/sh

set -e

BUILD_AREA=/opt/fdistdump/build_area
git config --global user.name "bodik"
git config --global user.email "bodik@cesnet.cz"
#git commit --amend --author="Radoslav Bodo <bodik@cesnet.cz>"

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
cd ..
for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/libnf-install" --name libnf --version ${VER} --iteration 1  \
		--description "libnf package from libnf.net/packages" --maintainer "bodik@cesnet.cz" --vendor "" --url "http://libnf.net"
done
dpkg -i libnf_${VER}-1_$(dpkg --print-architecture).deb


cd $BUILD_AREA || exit 1
VER=0.1
##git clone https://github.com/CESNET/fdistdump
##cd fdistdump || exit 1
##git checkout develop
##autoreconf -i
##CFLAGS="-I/opt/libnf/include" LDFLAGS="-L/opt/libnf/lib" ./configure --prefix=/opt/fdistdump
git clone https://github.com/bodik/fdistdump
cd fdistdump || exit 1
git checkout develop-bcompile
autoreconf -i
./configure
make
mkdir ${BUILD_AREA}/fdistdump-install
make DESTDIR="${BUILD_AREA}/fdistdump-install" install
cd ..
for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/fdistdump-install" --name fdistdump --version ${VER} --iteration 1  \
		--description "fdistdump from https://github.com/CESNET/fdistdump" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/fdistdump"
done
dpkg -i fdistdump_${VER}-1_$(dpkg --print-architecture).deb


sh /puppet/fdistdump/bin/get_test_data.sh
