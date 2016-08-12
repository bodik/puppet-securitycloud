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



# ipfixcol
if [ ! -f /usr/lib/ocf/resource.d/cesnet/ipfixcol.metadata ]; then
	rreturn 1 "$0 ipfixcol OCF metadata not present"
fi

if [ ! -f /usr/lib/ocf/resource.d/cesnet/ipfixcol.sh ]; then
	rreturn 1 "$0 ipfixcol OCF resource agent"
fi



if [ ! -f /data/conf/ipfixcol/startup-proxy.xml ]; then
	rreturn 1 "$0 ipfixcol startup-proxy.xml"
fi

if [ ! -f /data/conf/ipfixcol/startup-subcollector.xml ]; then
	rreturn 1 "$0 ipfixcol startup-subcollector.xml"
fi


# this is not nice, since there might be "vim ipfixcol.xml" running
# but the processes are named ipfixcol:udp-cpg and ipfixcol:TCP
# and simple check like this one does not have a clue about pacemaker logic ...
check_procs -a ipfixcol -c 1:2
if [ $? -ne 0 ]; then
	rreturn 1 "$0 ipfixcol check_procs"
fi



rreturn 0 "$0"
