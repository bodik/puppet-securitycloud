#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA


cd $BUILD_AREA
if [ ! -d ipfixcol ]; then
	#git clone https://github.com/CESNET/fdistdump --branch develop
	git clone https://github.com/bodik/fdistdump --branch develop-bcompile2
fi
cd fdistdump
IVER=$(cat configure.ac | grep AC_INIT | awk '{print $2}' | sed 's/[^0-9\.]//g')
GREV=$(git rev-parse --short HEAD)
VER="${IVER}.${GREV}"
cd $BUILD_AREA


cd fdistdump
autoreconf -i
./configure
make
mkdir ${BUILD_AREA}/fdistdump-install
make DESTDIR="${BUILD_AREA}/fdistdump-install" install
cd $BUILD_AREA
for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/fdistdump-install" --name fdistdump --version ${VER} --iteration 1  \
	        --depends libnf --depends openmpi-bin --depends openmpi-common --depends openmpi-doc \
		--description "fdistdump from https://github.com/CESNET/fdistdump" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/fdistdump"
done
dpkg -i fdistdump_${VER}-1_$(dpkg --print-architecture).deb

sh /puppet/fdistdump/bin/get_test_data.sh

