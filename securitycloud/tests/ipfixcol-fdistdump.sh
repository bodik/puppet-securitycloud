#!/bin/sh

. /puppet/metalib/bin/lib.sh

BASE=/var/lib/ipfixcol/lnfstore/
cd ${BASE} || exit 1

NODES=$(securitycloud.init list | awk '{printf $2","}')
MASTER=$(echo $NODES | awk -F',' '{print $1}')
mpirun --host $MASTER,$NODES fdistdump -s dstport "${BASE}"

rreturn $? "$0"
