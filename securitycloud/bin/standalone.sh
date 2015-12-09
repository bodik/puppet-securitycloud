#!/bin/sh
set -x

echo 'deb http://esb.metacentrum.cz/puppet-securitycloud-packages ./' > /etc/apt/sources.list.d/securitycloud.list
echo 'APT::Get::AllowUnauthenticated yes;' > /etc/apt/apt.conf.d/99auth
apt-get update
apt-get install fdistdump ipfixcol-base ipfixcol-plugins

dpkg -l fdistdump libnf ipfixcol-base ipfixcol-plugins

