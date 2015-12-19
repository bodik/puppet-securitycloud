#!/bin/sh
set -e

if command -v apt-get; then

wget -qO - http://esb.metacentrum.cz/puppet-securitycloud-packages/securitycloud.asc | apt-key add -
echo 'deb http://esb.metacentrum.cz/puppet-securitycloud-packages/debian jessie main' > /etc/apt/sources.list.d/securitycloud.list
apt-get update
apt-get -y install fdistdump ipfixcol
dpkg -l fdistdump libnf ipfixcol

fi


if command -v yum; then

rpm --import http://esb.metacentrum.cz/puppet-securitycloud-packages/securitycloud.asc
cat << __EOF__ > /etc/yum.repos.d/securitycloud.repo
[securitycloud]
name=securitycloud repo
baseurl=http://esb.metacentrum.cz/puppet-securitycloud-packages/redhat/centos7
enabled=1
gpgcheck=1
gpgkey=http://esb.metacentrum.cz/puppet-securitycloud-packages/securitycloud.asc
__EOF__
yum -y install fdistdump ipfixcol
rpm -q fdistdump libnf ipfixcol

fi

