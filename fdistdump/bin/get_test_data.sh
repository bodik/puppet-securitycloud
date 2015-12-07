#!/bin/sh

mkdir -p /scratch/fdistdump/data 1>/dev/null || exit 1
cd /opt/fdistdump || exit 1
if [ ! -d data ]; then
	ln -sfT /scratch/fdistdump/data/ /opt/fdistdump/data
	cd data || exit 1
	wget --no-parent -m --no-directories --no-verbose http://esb.metacentrum.cz/puppet-fdistdump.git-testdata/
	rm index.html
fi

