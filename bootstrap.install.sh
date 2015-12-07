apt-get update
apt-get install -y git puppet

if [ ! -d /puppet ]; then
	cd /
	git clone http://esb.metacentrum.cz/puppet-fdistdump.git
	ln -sf /puppet-fdistdump /puppet
else
	cd /puppet
	git remote set-url origin http://esb.metacentrum.cz/puppet-fdistdump.git
	git pull
fi

cd /puppet && git remote set-url origin bodik@esb.metacentrum.cz:/data/puppet-fdistdump.git

