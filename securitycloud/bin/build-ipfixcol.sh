#!/bin/sh

#prologue
set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA
puppet apply -e 'package { ["ipfixcol", "ipfixcol-buildstub"]: ensure => absent }'



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

case "$(facter osfamily)" in
    "Debian")	
	TGT="deb"
	PKGMANAGER="dpkg"
	DEPENDS="--depends libxml2 --depends openssl --depends liblzo2-2"
	RESULT1="ipfixcol-buildstub_${VER}-${PKGITER}_$(facter architecture).${TGT}"
	RESULT2="ipfixcol_${VER}-${PKGITER}_$(facter architecture).${TGT}"
	;;
    "RedHat")	
	TGT="rpm"
	PKGMANAGER="rpm"
	PATH="${PATH}:/usr/lib64/openmpi/bin"
	DEPENDS="--depends libxml2 --depends openssl --depends lzo"
	RESULT1="ipfixcol-buildstub-${VER}-${PKGITER}.$(facter architecture).${TGT}"
	RESULT2="ipfixcol-${VER}-${PKGITER}.$(facter architecture).${TGT}"
	;;
esac


#compile
cd $BUILD_AREA

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
mkdir -p ${BUILD_AREA}/ipfixcol-install/etc/ld.so.conf.d/
cp /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol.ld.so.conf ${BUILD_AREA}/ipfixcol-install/etc/ld.so.conf.d/
cp /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol.init ${BUILD_AREA}/ipfixcol-install/etc/init.d/ipfixcol
cp /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol.service ${BUILD_AREA}/ipfixcol-install/lib/systemd/system
mv ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/startup.xml ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/startup.xml.example
cp /puppet/securitycloud/files/packaging/ipfixcol/internalcfg.xml ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/
cp /puppet/securitycloud/files/packaging/ipfixcol/collector.xml.example ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/
cp /puppet/securitycloud/files/packaging/ipfixcol/proxy.xml.example ${BUILD_AREA}/ipfixcol-install/usr/local/etc/ipfixcol/

cd $BUILD_AREA
fpm -f -s dir -t ${TGT} -C "${BUILD_AREA}/ipfixcol-install" --name ipfixcol-buildstub --version ${VER} --iteration ${PKGITER}  \
	${DEPENDS} \
	--conflicts ipfixcol \
	--after-install /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol-buildstub.postinst --after-remove /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol-buildstub.postrm \
	--description "ipfixcol-buildstub from https://github.com/CESNET/ipfixcol with HEAD at ${GREV} (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"
${PKGMANAGER} -i ${RESULT1}

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
fpm -f -s dir -t ${TGT} -C "${BUILD_AREA}/ipfixcol-install" --name ipfixcol --version ${VER} --iteration ${PKGITER} \
	${DEPENDS} \
	--conflicts ipfixcol-buildstub \
	--after-install /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol.postinst --pre-uninstall /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol.prerm --after-remove /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol.postrm \
	--description "ipfixcol from https://github.com/CESNET/ipfixcol with HEAD at ${GREV} (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"

puppet apply -e 'package { "ipfixcol-buildstub": ensure => absent }'
${PKGMANAGER} -i ${RESULT2}

