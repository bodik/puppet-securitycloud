#!/bin/sh

. /puppet/metalib/bin/lib.sh
case "$(facter osfamily)" in
    "Debian")
	MPICMD="mpirun"
	;;
    "RedHat")	
	MPICMD="mpirun"
	module load mpi/mpich-x86_64
	;;
esac

BASE=/scratch/fdistdump/data
cd ${BASE} || exit 1

NODES=$(securitycloud.init list | awk '{printf $2","}')
MASTER=$(echo $NODES | awk -F',' '{print $1}')
$MPICMD --host $MASTER,$NODES fdistdump -s dstport "${BASE}"

rreturn $? "$0"
