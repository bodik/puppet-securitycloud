#!/bin/sh
set -x

case "$(facter osfamily)" in
    "Debian")
	wget -qO - http://esb.metacentrum.cz/puppet-securitycloud-packages/securitycloud.asc | apt-key add -
	echo 'deb http://esb.metacentrum.cz/puppet-securitycloud-packages/debian jessie main' > /etc/apt/sources.list.d/securitycloud.list
	apt-get update
	apt-get -y install fdistdump ipfixcol
	dpkg -l fdistdump libnf ipfixcol
    ;;
    "RedHat")
	echo "not implemented"
	exit 1
    ;;
esac


