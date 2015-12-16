#!/bin/sh

#prologue
set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA


#fetch sources
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


#compile
cd ipfixcol/base 
autoreconf -i
./configure
make
mkdir -p ${BUILD_AREA}/ipfixcol-install
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

mkdir -p ${BUILD_AREA}/ipfixcol-install/var/lib/ipfixcol/
mkdir -p ${BUILD_AREA}/ipfixcol-install/var/lib/ipfixcol/lnfstore/
mkdir -p ${BUILD_AREA}/ipfixcol-install/etc/init.d/
mkdir -p ${BUILD_AREA}/ipfixcol-install/lib/systemd/system
cp /puppet/securitycloud/files/packaging/ipfixcol.init ${BUILD_AREA}/ipfixcol-install/etc/init.d/ipfixcol
cp /puppet/securitycloud/files/packaging/ipfixcol.service ${BUILD_AREA}/ipfixcol-install/lib/systemd/system
mv ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/startup.xml ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/startup.xml.example
cp /puppet/securitycloud/files/packaging/internalcfg.xml ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/
cp /puppet/securitycloud/files/packaging/collector.xml.example ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/
cp /puppet/securitycloud/files/packaging/proxy.xml.example ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/

cd $BUILD_AREA
for target in deb rpm; do 
	fpm -f -s dir -t $target -C "${BUILD_AREA}/ipfixcol-install" --name ipfixcol-buildstub --version ${VER} --iteration ${PKGITER}  \
		--depends libxml2 --depends openssl \
		--conflicts ipfixcol \
		--after-install /puppet/securitycloud/files/packaging/ipfixcol-buildstub.postinst --after-remove /puppet/securitycloud/files/packaging/ipfixcol-buildstub.postrm \
		--description "ipfixcol-buildstub from https://github.com/CESNET/ipfixcol with HEAD at ${GREV} (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"
done
dpkg -i ipfixcol-buildstub_${VER}-1_$(dpkg --print-architecture).deb

cd ${BUILD_AREA}/ipfixcol/plugins/input/nfdump
autoreconf -i
./configure
make
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

cd ${BUILD_AREA}/ipfixcol/plugins/intermediate/profiler
autoreconf -i
./configure
make
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

cd ${BUILD_AREA}/ipfixcol/plugins/storage/json
autoreconf -i
./configure
make
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

cd ${BUILD_AREA}/ipfixcol/plugins/storage/lnfstore 
autoreconf -i
./configure
make
mkdir -p ${BUILD_AREA}/ipfixcol-plugins-install
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install


#make package
cd $BUILD_AREA
for target in deb rpm; do 
	fpm -f -s dir -t $target -C "${BUILD_AREA}/ipfixcol-install" --name ipfixcol --version ${VER} --iteration ${PKGITER} \
		--depends libxml2 --depends openssl --depends liblzo2-2 \
		--conflicts ipfixcol-buildstub \
		--after-install /puppet/securitycloud/files/packaging/ipfixcol.postinst --pre-uninstall /puppet/securitycloud/files/packaging/ipfixcol.prerm --after-remove /puppet/securitycloud/files/packaging/ipfixcol.postrm \
		--description "ipfixcol from https://github.com/CESNET/ipfixcol with HEAD at ${GREV} (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"
done
dpkg --purge ipfixcol-buildstub
dpkg -i ipfixcol_${VER}-1_$(dpkg --print-architecture).deb

