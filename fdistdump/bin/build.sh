#!/bin/sh

BUILD_AREA=/tmp/build_area

mkdir $BUILD_AREA

cd $BUILD_AREA || exit 1
wget http://libnf.net/packages/libnf-1.16.tar.gz
tar xzf libnf-1.16.tar.gz
cd libnf-1.16 || exit 1
./configure --prefix=/opt/libnf
make
make install

cd $BUILD_AREA || exit 1
git clone https://github.com/CESNET/fdistdump
cd fdistdump || exit 1
git checkout develop
autoreconf -i
LDFLAGS="-L/opt/libnf/lib" ./configure --prefix=/opt/fdistdump
make
make install

