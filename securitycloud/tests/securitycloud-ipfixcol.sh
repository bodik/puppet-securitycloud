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


rreturn 0 "$0"
