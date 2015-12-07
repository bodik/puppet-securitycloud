#!/bin/sh

. /puppet/metalib/bin/lib.sh

BASE=/opt/fdistdump
cd ${BASE} || exit 1

NODES=$(curl -s http://$(facter fqdn):39200/_cat/nodes | awk '{printf $1","}')
mpirun --host $NODES fdistdump -r "${BASE}/${flow_file}/data" -s dstport

rreturn $? "$0"
