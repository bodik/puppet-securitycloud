#!/bin/sh

SOURCE="/tmp/build_area"
FRONT='bodik@esb.metacentrum.cz'
BASE="/data/puppet-securitycloud-packages"
TARGET="${BASE}/debian"
GPGDIR="${BASE}/keys"

ssh $FRONT "rm -r ${TARGET}; mkdir -p ${TARGET} ${TARGET}/conf ${TARGET}/incomming"
scp ${SOURCE}/*deb ${FRONT}:${TARGET}/incomming
scp /puppet/securitycloud/files/packaging/reprepro-distributions ${FRONT}:${TARGET}/conf/distributions
ssh ${FRONT} "reprepro --gnupghome ${GPGDIR} -b ${TARGET} includedeb jessie ${TARGET}/incomming/*deb"

