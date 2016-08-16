#!/bin/sha

. /puppet/metalib/bin/lib.sh

echo "INFO: begin simple test"

echo "INFO: gstor cleanup"
securitycloud.init idrop
echo "INFO: cluster list"
securitycloud.init list
pcs status

echo "INFO: fetch ipfixcol testdata"
sh /puppet/securitycloud/bin/testdata-ipfixcol-get.sh


echo "INFO: stream testdata"
sh -x /puppet/securitycloud/tests/ipfixcol-stream.sh
echo "INFO: restarting ipfixcol services to flush streamed data"
securitycloud.init istop
securitycloud.init istart
echo "INFO: querying data"
FLOWS=3192195
PACKETS=90920552
BYTES=97051395875
sh /puppet/securitycloud/tests/ipfixcol-fdistdump.sh | grep "$FLOWS flows, $PACKETS packets, $BYTES bytes"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 results not correct"
fi

echo "INFO: end simple test"




echo "INFO: begin repetition test"

echo "INFO: gstor cleanup"
securitycloud.init idrop
echo "INFO: cluster list"
securitycloud.init list
pcs status

REPS=$(/bin/bash -c 'echo $(( $RANDOM % 10 ))')
echo "INFO: repeating stream tesdata $REPS times"
for i in $(seq 1 $REPS); do
	sh /puppet/securitycloud/tests/ipfixcol-stream.sh
done
echo "INFO: restarting ipfixcol services to flush streamed data"
securitycloud.init istop
securitycloud.init istart
echo "INFO: querying data"
FLOWS=$(( $REPS * $FLOWS))
PACKETS=$(( $REPS * $PACKETS))
BYTES=$(( $REPS * $BYTES))
sh /puppet/securitycloud/tests/ipfixcol-fdistdump.sh | grep "$FLOWS flows, $PACKETS packets, $BYTES bytes"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 repetition test results not correct"
fi

echo "INFO: end repetition test"


rreturn 0 "$0"
