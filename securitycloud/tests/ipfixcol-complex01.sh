#!/bin/sha
STARTTIME=$(date +%s)

. /puppet/metalib/bin/lib.sh

echo "INFO: begin simple test"

echo "INFO: gstor cleanup"
securitycloud.init idrop
echo "INFO: cluster list"
securitycloud.init list
pcs status

echo "INFO: stream example01"
sh /puppet/securitycloud/tests/ipfixcol-stream-example01.sh
echo "INFO: restarting ipfixcol services to flush streamed data"
securitycloud.init istop
securitycloud.init istart
echo "INFO: querying data"
FLOWS=3979
PACKETS=56695
BYTES=49001404
sh /puppet/securitycloud/tests/ipfixcol-fdistdump.sh 2>/dev/null | grep "$FLOWS flows, $PACKETS packets, $BYTES bytes"
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
echo "INFO: repeating stream example01 $REPS times"
for i in $(seq 1 $REPS); do
	sh /puppet/securitycloud/tests/ipfixcol-stream-example01.sh
done
echo "INFO: restarting ipfixcol services to flush streamed data"
securitycloud.init istop
securitycloud.init istart
echo "INFO: querying data"
FLOWS=$(( $REPS * $FLOWS))
PACKETS=$(( $REPS * $PACKETS))
BYTES=$(( $REPS * $BYTES))
sh /puppet/securitycloud/tests/ipfixcol-fdistdump.sh 2>/dev/null | grep "$FLOWS flows, $PACKETS packets, $BYTES bytes"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 repetition test results not correct"
fi

echo "INFO: end repetition test"


ENDTIME=$(date +%s)
SECONDS=$(( $ENDTIME - $STARTTIME))
DURATION=$(date -u -d @${SECONDS} +"%T")
rreturn 0 "$0 duration $DURATION seconds $SECONDS"
