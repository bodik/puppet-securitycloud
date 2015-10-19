#!/bin/sh

if [ -z $1 ]; then
	echo "ERROR: no service specified"
	exit 1
fi

IPS=$(avahi-browse -t $1 --resolve -p | grep "=;.*;IPv4;" | awk -F";" '{print $8}' | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n)

if [ -z "$IPS" ]; then
	exit 0
else
	for IP in $IPS; do
		HNAME=$(host -t A $IP)
		if [ $? -ne 0 ]; then
			echo $IP
		else
			echo $HNAME | rev | awk '{print $1}' | rev | sed 's/\.$//'
		fi
	done
fi
