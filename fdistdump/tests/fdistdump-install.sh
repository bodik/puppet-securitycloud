#!/bin/sh

. /puppet/metalib/bin/lib.sh


#fdd packages
dpkg -i libnf
if [ $? -ne 0 ]; then
	rreturn 1 "$0 missing libnf"
fi

dpkg -i fdistdump
if [ $? -ne 0 ]; then
	rreturn 1 "$0 missing fdistdump"
fi


#coordiantion component
/usr/lib/nagios/plugins/check_procs --argument-array=org.elasticsearch.bootstrap.Elasticsearch -c 1:1
if [ $? -ne 0 ]; then
	rreturn 1 "$0 org.elasticsearch.bootstrap.Elasticsearch check_procs"
fi

ESDAGE=$(ps h -o etimes $(pgrep -f org.elasticsearch.bootstrap.Elasticsearch))
if [ $ESDAGE -lt 60 ] ; then
	echo "INFO: ESD warming up"
	sleep 60
fi

netstat -nlpa | grep " $(pgrep -f org.elasticsearch.bootstrap.Elasticsearch)/java" | grep LISTEN | grep ":39200"
if [ $? -ne 0 ]; then
	rreturn 1 "$0 esd http listener"
fi

wget "http://$(facter fqdn):39200" -q -O /dev/null
if [ $? -ne 0 ]; then
	rreturn 1 "$0 esd http interface"
fi


rreturn 0 "$0 ok"

