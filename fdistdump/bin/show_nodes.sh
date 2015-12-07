#curl "http://$(facter fqdn):39200/_cat/nodes?v"
ruby /puppet/fdistdump/bin/show_nodes.rb $@

