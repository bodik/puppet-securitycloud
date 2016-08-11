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



# gluster procs
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

NUMBER_OF_NODES=$(/usr/bin/curl -s "http://$(facter fqdn):39200/_cat/nodes?h=host" | wc -l)
NUMBER_OF_NODES_CONNECTED=$(gluster pool list | grep Connected | wc -l)
if [ $NUMBER_OF_NODES -ne $NUMBER_OF_NODES_CONNECTED ]; then
	rreturn 1 "$0 gluster connected nodes"
fi



# glusterfs volumes
gluster volume info conf | grep Started 1>/dev/null
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume conf"
fi

gluster volume info flow | grep Started 1>/dev/null
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume flow"
fi

securitycloud.init all 'mount | grep "/data/conf type fuse.glusterfs"'
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume conf mounts"
fi

securitycloud.init all 'mount | grep "/data/flow type fuse.glusterfs"'
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume flow mounts"
fi



# glusterfs write read test
NODES=$(securitycloud.init list | awk '{print $1}' | shuf)
NODE_WRITE=$(echo $NODES | awk '{print $1}')
NODE_READ=$(echo $NODES | awk '{print $NF}')
TOKEN=$(/bin/dd if=/dev/urandom bs=100 count=1 2>/dev/null | /usr/bin/sha256sum | /usr/bin/awk '{print $1}')

VMNAME=$NODE_WRITE securitycloud.init ssh "echo $TOKEN > /data/conf/puppet-securitycloud-write-test"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume conf write"
fi
VMNAME=$NODE_READ securitycloud.init ssh "grep $TOKEN /data/conf/puppet-securitycloud-write-test"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume conf read"
fi
VMNAME=$NODE_WRITE securitycloud.init ssh "rm /data/conf/puppet-securitycloud-write-test"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume conf write cleanup"
fi

VMNAME=$NODE_WRITE securitycloud.init ssh "echo $TOKEN > /data/flow/puppet-securitycloud-write-test"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume flow write"
fi
VMNAME=$NODE_READ securitycloud.init ssh "grep $TOKEN /data/flow/puppet-securitycloud-write-test"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume flow read"
fi
VMNAME=$NODE_WRITE securitycloud.init ssh "rm /data/flow/puppet-securitycloud-write-test"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 gluster volume flow write cleanup"
fi



rreturn 0 "$0"
>>>>>>> Stashed changes
