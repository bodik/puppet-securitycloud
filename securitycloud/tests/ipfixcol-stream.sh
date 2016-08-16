for all in $(find /scratch/ipfixcol/data -type f); do
	echo "INFO: streaming $all $(ls -lh $all)"
	ipfixsend -i $all -d $(securitycloud.init virtualip) -R 1.0 -n 1
done
