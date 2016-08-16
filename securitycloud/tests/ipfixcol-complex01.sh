#!/bin/sha

. /puppet/metalib/bin/lib.sh

echo "INFO: gstor cleanup"
securitycloud.init idrop

echo "INFO: cluster list"
securitycloud.init list

echo "INFO: stream example01"
sh -x /puppet/securitycloud/tests/ipfixcol-stream-example01.sh

echo "INFO: restarting ipfixcol services to flush streamed data"
securitycloud.init istop
securitycloud.init istart

echo "INFO: querying data"
sh /puppet/securitycloud/tests/ipfixcol-fdistdump.sh | grep '3979 flows, 56695 packets, 49001404 bytes'
if [ $? -ne 0 ]; then
	rreturn 1 "$0 results not correct"
fi

rreturn 0 "$0"
