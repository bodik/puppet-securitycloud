#!/bin/sh

#prologue
set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA
puppet apply -e 'package { ["ipfixcol", "ipfixcol-buildstub"]: ensure => absent }'



#fetch sources
cd $BUILD_AREA
if [ ! -d ipfixcol ]; then
	#git clone https://github.com/CESNET/ipfixcol --branch master
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
	LIBDIR="/usr/lib/x86_64-linux-gnu/"
	;;
    "RedHat")	
	TGT="rpm"
	PKGMANAGER="rpm"
	DEPENDS="--depends libxml2 --depends openssl --depends lzo"
	RESULT1="ipfixcol-buildstub-${VER}-${PKGITER}.$(facter architecture).${TGT}"
	RESULT2="ipfixcol-${VER}-${PKGITER}.$(facter architecture).${TGT}"
	LIBDIR="/usr/lib64/"
	module load mpi/mpich-x86_64
	;;
esac


#compile
cd $BUILD_AREA

cd ipfixcol/base 
autoreconf -i
./configure --prefix=/usr/ --libdir=$LIBDIR --sysconfdir=/etc/
make
mkdir -p ${BUILD_AREA}/ipfixcol-install
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

mv ${BUILD_AREA}/ipfixcol-install/etc/ipfixcol/startup.xml ${BUILD_AREA}/ipfixcol-install/etc/ipfixcol/startup.xml.example

cd $BUILD_AREA
fpm -f -s dir -t ${TGT} -C "${BUILD_AREA}/ipfixcol-install" --name ipfixcol-buildstub --version ${VER} --iteration ${PKGITER}  \
	${DEPENDS} \
	--conflicts ipfixcol \
	--after-install /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol-buildstub.postinst --after-remove /puppet/securitycloud/files/packaging/ipfixcol/ipfixcol-buildstub.postrm \
	--description "ipfixcol-buildstub from https://github.com/CESNET/ipfixcol with HEAD at ${GREV} (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/ipfixcol"
${PKGMANAGER} -i ${RESULT1}

#UDP-CPG input plugin
cd ${BUILD_AREA}/ipfixcol/plugins/input/udp_cpg
autoreconf -i
./configure --prefix=/usr/ --libdir=$LIBDIR --sysconfdir=/etc/
make
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

#libnf storage plugin
cd ${BUILD_AREA}/ipfixcol/plugins/storage/lnfstore 
autoreconf -i
./configure --prefix=/usr/ --libdir=$LIBDIR --sysconfdir=/etc/
make
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

#JSON storage plugin (optional, for flow streaming in JSON)
cd ${BUILD_AREA}/ipfixcol/plugins/storage/json
autoreconf -i
./configure --prefix=/usr/ --libdir=$LIBDIR --sysconfdir=/etc/
make
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

# release01 legacy
cd ${BUILD_AREA}/ipfixcol/plugins/input/nfdump
autoreconf -i
./configure --prefix=/usr/ --libdir=$LIBDIR --sysconfdir=/etc/
make
make DESTDIR="${BUILD_AREA}/ipfixcol-install" install

# release01 legacy
cd ${BUILD_AREA}/ipfixcol/plugins/intermediate/profiler
autoreconf -i
./configure --prefix=/usr/ --libdir=$LIBDIR --sysconfdir=/etc/
make
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

