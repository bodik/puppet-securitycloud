#!/bin/sh

#prologue
set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA



#fetch sources
cd $BUILD_AREA
if [ ! -d nf-tools ]; then
	git clone https://github.com/VUTBR/nf-tools.git --branch master
fi
cd nf-tools/libnf/c/
VER=$(cat configure.ac | grep AC_INIT | awk '{print $2}' | sed 's/[^0-9\.]//g')
GREV=$(git rev-parse --short HEAD)
PKGITER="1"

case "$(facter osfamily)" in
    "Debian")	
	TGT="deb"
	PKGMANAGER="dpkg"
	DEPENDS=""
	RESULT="libnf_${VER}-${PKGITER}_$(facter architecture).${TGT}"
	LIBDIR="/usr/lib/x86_64-linux-gnu/"
	;;
    "RedHat")	
	TGT="rpm"
	PKGMANAGER="rpm"
	DEPENDS=""
	RESULT="libnf-${VER}-${PKGITER}.$(facter architecture).${TGT}"
	LIBDIR="/usr/lib64/"
	module load mpi/mpich-x86_64
	;;
esac



#compile
cd $BUILD_AREA

cd nf-tools/libnf/c/
./prepare-nfdump.sh
autoreconf -i
./configure --prefix=/usr/ --libdir=$LIBDIR
make
mkdir ${BUILD_AREA}/libnf-install
make DESTDIR="${BUILD_AREA}/libnf-install" install



#make package
cd $BUILD_AREA
fpm -f -s dir -t ${TGT} -C "${BUILD_AREA}/libnf-install" --name libnf --version ${VER} --iteration ${PKGITER}  \
	--after-install /puppet/securitycloud/files/packaging/libnf/libnf.postinst --after-remove /puppet/securitycloud/files/packaging/libnf/libnf.postrm \
	--description "libnf package from https://github.com/VUTBR/nf-tools.git with HEAD at ${GREV} (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/VUTBR/nf-tools.git"

${PKGMANAGER} -i ${RESULT}

