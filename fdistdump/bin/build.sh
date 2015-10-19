#!/bin/sh

BASE=/opt/fdistdump
BUILD_AREA=${BASE}/build_area
git config --global user.name "bodik"
git config --global user.email "bodik@cesnet.cz"
#git commit --amend --author="Radoslav Bodo <bodik@cesnet.cz>"

mkdir -p $BASE
mkdir -p $BUILD_AREA

cd $BUILD_AREA || exit 1
wget http://libnf.net/packages/libnf-1.16.tar.gz
tar xzf libnf-1.16.tar.gz
cd libnf-1.16 || exit 1
./configure --prefix=/opt/fdistdump
make
make install
echo "/opt/fdistdump/lib" > /etc/ld.so.conf.d/fdistdump-libnf.conf
ldconfig

cd $BUILD_AREA || exit 1
##git clone https://github.com/CESNET/fdistdump
##cd fdistdump || exit 1
##git checkout develop
##autoreconf -i
##CFLAGS="-I/opt/libnf/include" LDFLAGS="-L/opt/libnf/lib" ./configure --prefix=/opt/fdistdump
git clone https://github.com/bodik/fdistdump
cd fdistdump || exit 1
git checkout develop-bcompile
autoreconf -i
./configure --prefix=/opt/fdistdump --with-libnf-dir=/opt/fdistdump/
make
make install

cd ${BASE} || exit 1
if [ ! -d data ]; then
	mkdir data
	cd data || exit 1
	wget --no-parent -m --no-directories http://esb.metacentrum.cz/puppet-fdistdump.git-testdata/
fi

