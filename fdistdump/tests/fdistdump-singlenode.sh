#!/bin/sh

. /puppet/metalib/bin/lib.sh

BASE="/scratch/fdistdump/data"
cd ${BASE} || exit 1
for flow_file in $(find . -name "nfcapd*"); do
	CMD="mpirun -np 2 fdistdump -r ${flow_file} -s dstport"
	$CMD
	if [ $? -ne 0 ]; then
		rreturn 1 "$0 $CMD"
	fi
done

rreturn 0 "$0 ok"

