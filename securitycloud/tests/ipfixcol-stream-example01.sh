#!/bin/sh

ipfixsend -i /usr/local/SecurityCloud/ipfixcol/examples/01_QuickStartGuide/example_flows.ipfix -d $(securitycloud.init virtualip) -R 1.0 -n 1

