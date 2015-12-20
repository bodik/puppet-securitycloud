if command -v apt-get >/dev/null; then
	apt-get update
	apt-get install -y git puppet
fi
if command -v yum >/dev/null; then
	yum install -y git puppet
fi

if [ ! -d /puppet ]; then
	cd /usr/local/
	git clone http://esb.metacentrum.cz/puppet-securitycloud.git
	ln -sf /usr/local/puppet-securitycloud /puppet
else
	cd /puppet
	git remote set-url origin http://esb.metacentrum.cz/puppet-securitycloud.git
	git pull
fi

cd /puppet && git remote set-url origin bodik@esb.metacentrum.cz:/data/puppet-securitycloud.git

