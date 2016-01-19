for all in $(find /scratch/ipfixcol/data -type f); do
	echo "INFO: streaming $all $(ls -lh $all)"
	ipfixsend -i $all -d "$(securitycloud.init proxy)" -n 1 -t UDP -p 4739 -s 5M
done
