#!/bin/sh

echo "INFO: gstor cleanup"
securitycloud.init idrop
sleep 10
echo "INFO: cluster list"
securitycloud.init list
sleep 10

for all in $(seq 1 5); do
	echo "INFO: begin stream and query round $all"
	echo "INFO: stream example01"
	sh securitycloud/tests/ipfixcol-stream-example01.sh
	echo "INFO: query data 1"
	sh securitycloud/tests/ipfixcol-fdistdump.sh
	echo "INFO: sleep 300"
	sleep 300
	echo "INFO: query data 2"
	sh securitycloud/tests/ipfixcol-fdistdump.sh
	echo "INFO: end stream and query round $all"
done

