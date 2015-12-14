#!/bin/sh

DIR="/scratch/ipfixcol/data"
if [ ! -d $DIR ]; then
	mkdir -p $DIR 1>/dev/null || exit 1
	cd $DIR || exit 1
	wget --no-parent -m --no-directories --no-verbose http://esb.metacentrum.cz/puppet-securitycloud.git-testdata/ipfixcol/
	rm index.html
fi

