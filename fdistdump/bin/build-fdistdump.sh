#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA

cd $BUILD_AREA || exit 1
VER=0.2

#git clone https://github.com/CESNET/fdistdump
#cd fdistdump || exit 1
#git checkout develop
#autoreconf -i

git clone https://github.com/bodik/fdistdump
cd fdistdump || exit 1
git checkout develop-bcompile2
autoreconf -i

./configure
make
mkdir ${BUILD_AREA}/fdistdump-install
make DESTDIR="${BUILD_AREA}/fdistdump-install" install
make DESTDIR="${BUILD_AREA}/compact-install" install
cd ..
for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/fdistdump-install" --name fdistdump --version ${VER} --iteration 1  \
	        --depends libnf --depends openmpi-bin --depends openmpi-common --depends openmpi-doc \
		--description "fdistdump from https://github.com/CESNET/fdistdump" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/fdistdump"
done
dpkg -i fdistdump_${VER}-1_$(dpkg --print-architecture).deb

sh /puppet/fdistdump/bin/get_test_data.sh

