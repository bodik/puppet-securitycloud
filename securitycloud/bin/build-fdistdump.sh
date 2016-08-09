#!/bin/sh

#prologue
set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA



#fetch sources
cd $BUILD_AREA
if [ ! -d fdistdump ]; then
	#git clone https://github.com/CESNET/fdistdump --branch master
	git clone https://github.com/CESNET/fdistdump --branch develop
	#git clone https://github.com/bodik/fdistdump --branch develop-bcompile2
fi
cd fdistdump
VER=$(cat configure.ac | grep AC_INIT | awk '{print $2}' | sed 's/[^0-9\.]//g')
GREV=$(git rev-parse --short HEAD)
PKGITER="1"
cd $BUILD_AREA

case "$(facter osfamily)" in
    "Debian")	
	TGT="deb"
	PKGMANAGER="dpkg"
	DEPENDS="--depends libnf --depends openmpi-bin --depends openmpi-common --depends openmpi-doc"
	RESULT="fdistdump_${VER}-${PKGITER}_$(facter architecture).${TGT}"
	;;
    "RedHat")	
	TGT="rpm"
	PKGMANAGER="rpm"
	PATH="${PATH}:/usr/lib64/openmpi/bin"
	DEPENDS="--depends libnf --depends openmpi"
	RESULT="fdistdump-${VER}-${PKGITER}.$(facter architecture).${TGT}"
	;;
esac



#compile
cd $BUILD_AREA

cd fdistdump
autoreconf -i
./configure --prefix=/usr/
make
mkdir -p ${BUILD_AREA}/fdistdump-install
make DESTDIR="${BUILD_AREA}/fdistdump-install" install



#make package
cd $BUILD_AREA
fpm -f -s dir -t ${TGT} -C "${BUILD_AREA}/fdistdump-install" --name fdistdump --version ${VER} --iteration ${PKGITER}  \
        ${DEPENDS} \
	--description "fdistdump from https://github.com/CESNET/fdistdump with HEAD at ${GREV} (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/CESNET/fdistdump"

${PKGMANAGER} -i ${RESULT}

sh /puppet/securitycloud/bin/testdata-fdistdump-get.sh

