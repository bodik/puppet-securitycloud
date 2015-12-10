#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA


cd $BUILD_AREA
if [ ! -d ipfixcol ]; then
	git clone https://github.com/CESNET/ipfixcol --branch devel
	#git clone https://github.com/bodik/ipfixcol --branch devel-bcompile
fi
cd ipfixcol/base 
VER=$(cat configure.ac | grep AC_INIT | awk '{print $2}' | sed 's/[^0-9\.]//g')
GREV=$(git rev-parse --short HEAD)
PKGITER="1"
cd $BUILD_AREA


cd ipfixcol/base 
autoreconf -i
./configure
make
mkdir -p ${BUILD_AREA}/ipfixcol-base-install
make DESTDIR="${BUILD_AREA}/ipfixcol-base-install" install
cd $BUILD_AREA
for target in deb rpm; do 
	fpm -f -s dir -t $target -C "${BUILD_AREA}/ipfixcol-base-install" --name ipfixcol-base --version ${VER} --iteration ${PKGITER}  \
		--depends libxml2 --depends openssl \
		--after-install /puppet/securitycloud/files/ipfixcol-base.postinst --after-remove /puppet/securitycloud/files/ipfixcol-base.postrm \
		--description "ipfixcol-base from https://github.com/CESNET/ipfixcol with HEAD at ${GREV}" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"
done
dpkg -i ipfixcol-base_${VER}-1_$(dpkg --print-architecture).deb


mkdir -p ${BUILD_AREA}/ipfixcol-plugins-install

cd ${BUILD_AREA}/ipfixcol/plugins/input/nfdump
autoreconf -i
./configure
make
make DESTDIR="${BUILD_AREA}/ipfixcol-plugins-install" install

cd ${BUILD_AREA}/ipfixcol/plugins/intermediate/profiler
autoreconf -i
./configure
make
make DESTDIR="${BUILD_AREA}/ipfixcol-plugins-install" install

cd ${BUILD_AREA}/ipfixcol/plugins/storage/json
autoreconf -i
./configure
make
make DESTDIR="${BUILD_AREA}/ipfixcol-plugins-install" install

cd ${BUILD_AREA}/ipfixcol/plugins/storage/lnfstore 
autoreconf -i
./configure
make
mkdir -p ${BUILD_AREA}/ipfixcol-plugins-install
make DESTDIR="${BUILD_AREA}/ipfixcol-plugins-install" install

cd $BUILD_AREA
for target in deb rpm; do 
	fpm -f -s dir -t $target -C "${BUILD_AREA}/ipfixcol-plugins-install" --name ipfixcol-plugins --version ${VER} --iteration ${PKGITER} \
		--depends libxml2 --depends ipfixcol-base --depends liblzo2-2 \
		--description "ipfixcol-plugins from https://github.com/CESNET/ipfixcol with HEAD at ${GREV}" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"
done
dpkg -i ipfixcol-plugins_${VER}-1_$(dpkg --print-architecture).deb

