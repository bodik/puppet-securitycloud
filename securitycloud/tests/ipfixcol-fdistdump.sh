#!/bin/sh

. /puppet/metalib/bin/lib.sh

BASE=/var/lib/ipfixcol/lnfstore/
cd ${BASE} || exit 1

DATA=$(securitycloud.init list | grep " data " | awk '{printf $2","}')
MASTER=$(securitycloud.init list | grep " master " | awk '{print $2}')
mpirun --host $MASTER,$DATA fdistdump -s dstport "${BASE}"

rreturn $? "$0"
