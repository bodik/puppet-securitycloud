#!/bin/sh


while(true); do 
	sh securitycloud/tests/ipfixcol-complex01.sh | grep RESULT
	sh securitycloud/tests/ipfixcol-complex02.sh | grep RESULT
done


