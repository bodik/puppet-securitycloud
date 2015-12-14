#!/bin/sh
set -x

echo 'deb http://esb.metacentrum.cz/puppet-securitycloud-packages ./' > /etc/apt/sources.list.d/securitycloud.list
echo 'APT::Get::AllowUnauthenticated yes;' > /etc/apt/apt.conf.d/99auth
apt-get update
apt-get install -y fdistdump ipfixcol

dpkg -l fdistdump libnf ipfixcol

