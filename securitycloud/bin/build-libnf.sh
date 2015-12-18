#!/bin/sh

#prologue
set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA



#fetch sources
cd $BUILD_AREA
VER=1.16
PKGITER="1"
wget http://libnf.net/packages/libnf-${VER}.tar.gz
tar xzf libnf-${VER}.tar.gz

case "$(facter osfamily)" in
    "Debian")	
	TGT="deb"
	PKGMANAGER="dpkg"
	DEPENDS=""
	RESULT="libnf_${VER}-${PKGITER}_$(facter architecture).${TGT}"
	;;
    "RedHat")	
	TGT="rpm"
	PKGMANAGER="rpm"
	PATH="${PATH}:/usr/lib64/openmpi/bin"
	DEPENDS=""
	RESULT="libnf-${VER}-${PKGITER}.$(facter architecture).${TGT}"
	;;
esac



#compile
cd $BUILD_AREA

cd libnf-${VER} 
./configure
make
mkdir ${BUILD_AREA}/libnf-install
make DESTDIR="${BUILD_AREA}/libnf-install" install
mkdir -p ${BUILD_AREA}/libnf-install/etc/ld.so.conf.d/
cp /puppet/securitycloud/files/packaging/libnf/libnf.ld.so.conf ${BUILD_AREA}/libnf-install/etc/ld.so.conf.d/



#make package
cd $BUILD_AREA
fpm -f -s dir -t ${TGT} -C "${BUILD_AREA}/libnf-install" --name libnf --version ${VER} --iteration ${PKGITER}  \
	--after-install /puppet/securitycloud/files/packaging/libnf/libnf.postinst --after-remove /puppet/securitycloud/files/packaging/libnf/libnf.postrm \
	--description "libnf package from libnf.net/packages (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "http://libnf.net"

${PKGMANAGER} -i ${RESULT}

