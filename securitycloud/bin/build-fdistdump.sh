#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA


cd $BUILD_AREA
if [ ! -d fdistdump ]; then
	#git clone https://github.com/CESNET/fdistdump --branch develop
	git clone https://github.com/bodik/fdistdump --branch develop-bcompile2
fi
cd fdistdump
VER=$(cat configure.ac | grep AC_INIT | awk '{print $2}' | sed 's/[^0-9\.]//g')
GREV=$(git rev-parse --short HEAD)
PKGITER="1"
cd $BUILD_AREA


cd fdistdump
autoreconf -i
./configure
make
mkdir -p ${BUILD_AREA}/fdistdump-install
make DESTDIR="${BUILD_AREA}/fdistdump-install" install
cd $BUILD_AREA
for target in deb rpm; do 
	fpm -f -s dir -t $target -C "${BUILD_AREA}/fdistdump-install" --name fdistdump --version ${VER} --iteration ${PKGITER}  \
	        --depends libnf --depends openmpi-bin --depends openmpi-common --depends openmpi-doc \
		--description "fdistdump from https://github.com/CESNET/fdistdump with HEAD at ${GREV}" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/fdistdump"
done
dpkg -i fdistdump_${VER}-1_$(dpkg --print-architecture).deb

sh /puppet/securitycloud/bin/get_test_data.sh

