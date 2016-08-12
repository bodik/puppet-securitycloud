#!/bin/sh

. /puppet/metalib/bin/lib.sh
case "$(facter osfamily)" in
    "Debian")
	PKGMANAGER="dpkg -l"
	PATH="${PATH}:/usr/lib/nagios/plugins"
	;;
    "RedHat")	
	PKGMANAGER="rpm -qa"
	PATH="${PATH}:/usr/lib64/nagios/plugins"
	;;
esac



# corosync
if [ ! -f /etc/corosync/corosync.conf ]; then
	rreturn 1 "$0 corosync config missing"
fi

check_procs -C corosync -c 1:1
if [ $? -ne 0 ]; then
	rreturn 1 "$0 corosync check_procs"
fi

check_procs -a pacemaker -c 7:7
if [ $? -ne 0 ]; then
	rreturn 1 "$0 pacemaker check_procs"
fi



# cpg processes
TEMPFILE=$(mktemp)
corosync-cpgtool -d ' ' 1>${TEMPFILE} 2>&1
NUMBER_OF_NODES=$(securitycloud.init allnodes | wc -w)

NUMBER_OF_PROCS=$(grep crmd $TEMPFILE | wc -l)
if [ $NUMBER_OF_NODES -ne $NUMBER_OF_PROCS ]; then
	rreturn 1 "$0 pacemaker crmd process count"
fi

NUMBER_OF_PROCS=$(grep attrd $TEMPFILE | wc -l)
if [ $NUMBER_OF_NODES -ne $NUMBER_OF_PROCS ]; then
	rreturn 1 "$0 pacemaker attrd process count"
fi

NUMBER_OF_PROCS=$(grep stonith-ng $TEMPFILE | wc -l)
if [ $NUMBER_OF_NODES -ne $NUMBER_OF_PROCS ]; then
	rreturn 1 "$0 pacemaker stonith-ng process count"
fi

NUMBER_OF_PROCS=$(grep cib $TEMPFILE | wc -l)
if [ $NUMBER_OF_NODES -ne $NUMBER_OF_PROCS ]; then
	rreturn 1 "$0 pacemaker cib process count"
fi

NUMBER_OF_PROCS=$(grep pacemakerd $TEMPFILE | wc -l)
if [ $NUMBER_OF_NODES -ne $NUMBER_OF_PROCS ]; then
	rreturn 1 "$0 pacemaker pacemakerd process count"
fi

rm -f ${TEMPFILE}



# pcs settings check
VAL1=$(grep gfs_flow_backup_brick /usr/local/SecurityCloud/install/install.conf  | awk -F'=' '{print $2}')
VAL2=$(pcs property show | grep flow-backup-brick: | awk '{print $2}')
if [ "$VAL1" != "$VAL2" ]; then
	rreturn 1 "$0 pcs backup brick does not match config"
fi

VAL1=$(grep gfs_flow_primary_brick /usr/local/SecurityCloud/install/install.conf  | awk -F'=' '{print $2}')
VAL2=$(pcs property show | grep flow-primary-brick: | awk '{print $2}')
if [ "$VAL1" != "$VAL2" ]; then
	rreturn 1 "$0 pcs primary brick does not match config"
fi

NUMBER_OF_SUCCESSORS=$(pcs property show | grep successor | wc -l)
if [ $NUMBER_OF_NODES -ne $NUMBER_OF_SUCCESSORS ]; then
	rreturn 1 "$0 pcs successors"
fi


ping -c2 -w1 $(securitycloud.init virtualip)
if [ $? -ne 0 ]; then
	rreturn 1 "$0 virtualip not reachable"
fi


rreturn 0 "$0"
