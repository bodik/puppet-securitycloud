for all in $(find /scratch/ipfixcol/data -type f); do
	echo "INFO: streaming $all $(ls -l $all)"
	ipfixsend -i $all -d "$(securitycloud.init proxy)" -n 1 -t TCP -p 4739
done