#!/bin/sh

. /puppet/metalib/bin/lib.sh

fdistdump-ha -f "-s srcport" $(date +%Y)

rreturn $? "$0"
