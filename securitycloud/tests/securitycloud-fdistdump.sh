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



# fdistdump
whereis fdistdump-ha | grep fdistdump-ha
if [ $? -ne 0 ]; then
	rreturn 1 "$0 fdistdump-ha missing"
fi


rreturn 0 "$0"
