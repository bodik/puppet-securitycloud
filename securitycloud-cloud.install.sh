#!/bin/sh
set -e

securitycloud.init trustmesh

pa.sh -e "include securitycloud::cloud"

cd /usr/local/SecurityCloud/install/
./install.sh check
./install.sh glusterfs 
./install.sh ipfixcol
./install.sh fdistdump
./install.sh stack
./install.sh stack

cd /puppet
sh securitycloud/tests/securitycloud-cluster.sh
sh securitycloud/tests/securitycloud-glusterfs.sh
sh securitycloud/tests/securitycloud-ipfixcol.sh
sh securitycloud/tests/securitycloud-fdistdump.sh
sh securitycloud/tests/securitycloud-stack.sh

