#!/bin/sh
set -x

echo 'deb http://esb.metacentrum.cz/puppet-fdistdump-packages ./' > /etc/apt/sources.list.d/fdistdump.list
echo 'APT::Get::AllowUnauthenticated yes;' > /etc/apt/apt.conf.d/99auth
apt-get update
apt-get install -y fdistdump ipfixcol-base ipfixcol-plugins
dpkg -l fdistdump libnf pfixcol-base ipfixcol-plugins

