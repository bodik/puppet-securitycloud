#!/bin/sh

. /puppet/metalib/bin/lib.sh

fdistdump-ha --fdistdump-args "-s srcport --output-volume-conv=none" $(date +%Y)
rreturn $? "$0"
