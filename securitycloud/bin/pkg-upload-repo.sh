#!/bin/sh

SOURCE="/tmp/build_area"
FRONT='bodik@esb.metacentrum.cz'
BASE="/data/puppet-securitycloud-packages"
GPGDIR="${BASE}/keys"

TARGET="${BASE}/debian"
ssh $FRONT "rm -r ${TARGET}; mkdir -p ${TARGET} ${TARGET}/conf ${TARGET}/incomming"
scp ${SOURCE}/*deb ${FRONT}:${TARGET}/incomming
scp /puppet/securitycloud/files/packaging/reprepro-distributions ${FRONT}:${TARGET}/conf/distributions
ssh ${FRONT} "reprepro --gnupghome ${GPGDIR} -b ${TARGET} includedeb jessie ${TARGET}/incomming/*deb"

TARGET="${BASE}/redhat"
ssh $FRONT "rm -r ${TARGET}; mkdir -p ${TARGET}"
scp ${SOURCE}/*rpm ${FRONT}:${TARGET}
ssh ${FRONT} "GNUPGHOME=${GPGDIR} rpmsign --addsign --key-id=0811EDEA ${TARGET}/*rpm"
ssh ${FRONT} "createrepo ${TARGET}"

