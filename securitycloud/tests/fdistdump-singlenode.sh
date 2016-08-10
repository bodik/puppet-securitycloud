#!/bin/sh

. /puppet/metalib/bin/lib.sh
case "$(facter osfamily)" in
    "Debian")
	MPICMD="mpirun"
	;;
    "RedHat")	
	MPICMD="mpirun --allow-run-as-root"
	module load mpi/mpich-x86_64
	;;
esac



BASE="/scratch/fdistdump/data"
cd ${BASE} || exit 1
for flow_file in $(find . -name "nfcapd*"); do
	CMD="$MPICMD -np 2 fdistdump -s dstport ${flow_file}"
	$CMD
	if [ $? -ne 0 ]; then
		rreturn 1 "$0 $CMD"
	fi
done

rreturn 0 "$0 ok"

