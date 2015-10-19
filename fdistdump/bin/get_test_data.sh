#!/bin/sh

cd /opt/fdistdump || exit 1
if [ ! -d data ]; then
	mkdir data
	cd data || exit 1
	wget --no-parent -m --no-directories http://esb.metacentrum.cz/puppet-fdistdump.git-testdata/
fi

