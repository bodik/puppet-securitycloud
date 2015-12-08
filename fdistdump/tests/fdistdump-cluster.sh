#!/bin/sh

. /puppet/metalib/bin/lib.sh

BASE=/scratch/fdistdump/data
cd ${BASE} || exit 1

NODES=$(cluster.init list | awk '{printf $2","}')
MASTER=$(echo $NODES | awk -F',' '{print $1}')
mpirun --host $MASTER,$NODES fdistdump -r "${BASE}" -s dstport

rreturn $? "$0"
