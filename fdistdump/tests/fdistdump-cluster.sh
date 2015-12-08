#!/bin/sh

. /puppet/metalib/bin/lib.sh

BASE=/scratch/fdistdump/data
cd ${BASE} || exit 1

NODES=$(cluster.init list | awk '{printf $2","}')
MASTER=$(echo $NODES | awk -F',' '{print $1}')
mpirun --host $MASTER,$NODE fdistdump -s dstport "${BASE}"

rreturn $? "$0"
