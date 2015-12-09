#!/bin/sh

DIR="/scratch/fdistdump/data"
if [ ! -d $DIR ]; then
	mkdir -p $DIR 1>/dev/null || exit 1
	cd $DIR || exit 1
	wget --no-parent -m --no-directories --no-verbose http://esb.metacentrum.cz/puppet-securitycloud.git-testdata/
	rm index.html
fi

