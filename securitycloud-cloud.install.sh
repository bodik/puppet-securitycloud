#!/bin/sh
set -e

pa.sh -e "include securitycloud::cloud"

cd /usr/local/SecurityCloud/install/
./install.sh check
./install.sh glusterfs 
./install.sh ipfixcol
./install.sh fdistdump
./install.sh stack
./install.sh stack

