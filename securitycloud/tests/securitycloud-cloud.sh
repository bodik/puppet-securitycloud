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

#gluster fs procs
check_procs -C glusterd -c 1:1
if [ $? -ne 0 ]; then
	rreturn 1 "$0 glusterd check_procs"
fi

check_procs -C glusterfs -c 2:
if [ $? -ne 0 ]; then
	rreturn 1 "$0 glusterfs check_procs"
fi

check_procs -C glusterfsd -c 2:
if [ $? -ne 0 ]; then
	rreturn 1 "$0 glusterfsd check_procs"
fi


#gluster fs connections
NUMBER_OF_CONNECTIONS=$(netstat -tavn | grep "2400[7|8]" | wc -l)
if [ $NUMBER_OF_CONNECTIONS -lt 10 ]; then
	rreturn 1 "$0 gluster connections"
fi


