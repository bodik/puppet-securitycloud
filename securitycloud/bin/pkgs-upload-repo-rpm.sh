#!/bin/sh

SOURCE="/tmp/build_area"
FRONT='bodik@esb.metacentrum.cz'
BASE="/data/puppet-securitycloud-packages"
GPGDIR="${BASE}/keys"
TARGET="${BASE}/redhat"

ssh $FRONT "rm -r ${TARGET}; mkdir -p ${TARGET}"
scp ${SOURCE}/*rpm ${FRONT}:${TARGET}
ssh ${FRONT} "GNUPGHOME=${GPGDIR} rpmsign --addsign --key-id=0811EDEA ${TARGET}/*rpm"
ssh ${FRONT} "createrepo ${TARGET}"

