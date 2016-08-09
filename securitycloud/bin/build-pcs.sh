#!/bin/sh

#prologue
set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA



#fetch sources
cd $BUILD_AREA
if [ ! -d pcs ]; then
	git clone https://github.com/ClusterLabs/pcs.git --branch master
fi
cd pcs
VER=$(cat setup.py  | grep version | awk -F"'" '{print $2}')
GREV=$(git rev-parse --short HEAD)
PKGITER="1"
cd $BUILD_AREA

case "$(facter osfamily)" in
    "Debian")	
	TGT="deb"
	PKGMANAGER="dpkg"
	DEPENDS="--depends python-lxml"
	RESULT="pcs_${VER}-${PKGITER}_$(facter architecture).${TGT}"
	;;
    "RedHat")
	echo "INFO: pcs is not being build for Redhat platforms"
	exit 0
	;;
esac



#compile
cd $BUILD_AREA

cd pcs
make
mkdir -p ${BUILD_AREA}/pcs-install
make DESTDIR="${BUILD_AREA}/pcs-install" install



#make package
cd $BUILD_AREA
fpm -f -s dir -t ${TGT} -C "${BUILD_AREA}/pcs-install" --name pcs --version ${VER} --iteration ${PKGITER}  \
	${DEPENDS} \
	--description "pcs from https://github.com/ClusterLabs/pcs.git with HEAD at ${GREV} (build SecurityCloud)" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/ClusterLabs/pcs.git"

${PKGMANAGER} -i ${RESULT}


