apt-get update
apt-get install -y git puppet

if [ ! -d /puppet ]; then
	cd /
	git clone http://esb.metacentrum.cz/puppet-securitycloud.git
	ln -sf /puppet-securitycloud /puppet
else
	cd /puppet
	git remote set-url origin http://esb.metacentrum.cz/puppet-securitycloud.git
	git pull
fi

cd /puppet && git remote set-url origin bodik@esb.metacentrum.cz:/data/puppet-securitycloud.git

