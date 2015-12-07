for all in $(/puppet/fdistdump/show_nodes.sh | awk '{print $2}'); do
	ssh root@$all $1
done
