#!/bin/sha

. /puppet/metalib/bin/lib.sh

echo "INFO: gstor cleanup"
securitycloud.init idrop

echo "INFO: cluster list"
securitycloud.init list

echo "INFO: stream example01"
sh /puppet/securitycloud/tests/ipfixcol-stream-example01.sh

echo "INFO: restarting ipfixcol services to flush streamed data"
securitycloud.init istop
securitycloud.init istart

echo "INFO: querying data"
sh /puppet/securitycloud/tests/ipfixcol-fdistdump.sh | grep 'processed data summary: 4.0 k flows, 56.7 k packets, 49.0 M bytes'
if [ $? -ne 0 ]; then
	rreturn 1 "$0 results not correct"
fi

