#!/bin/sh

set -e
BUILD_AREA=/tmp/build_area
mkdir -p $BUILD_AREA

cd $BUILD_AREA || exit 1
VER=0.1

mkdir -p "${BUILD_AREA}/puppet-fdistdump-install/puppet-fdistdump"
cd /puppet-fdistdump
git archive HEAD --format tar | tar x -C  ${BUILD_AREA}/puppet-fdistdump-install/puppet-fdistdump
ln -vsf /puppet-fdistdump ${BUILD_AREA}/puppet-fdistdump-install/puppet
cd $BUILD_AREA || exit 1

for target in deb rpm; do 
	fpm -s dir -t $target -C "${BUILD_AREA}/puppet-fdistdump-install" --name puppet-fdistdump --version ${VER} --iteration 1  \
		--depends puppet --depends git --depends nagios-plugins-basic --depends psmisc \
		--description "fdistdump from https://github.com/bodik/puppet-fdistdump" --maintainer "bodik@cesnet.cz" --vendor "" --url "https://github.com/bodik/puppet-fdistdump"
done

