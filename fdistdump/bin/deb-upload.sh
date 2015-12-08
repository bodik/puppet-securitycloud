
FRONT='bodik@esb.metacentrum.cz'
REPO="/data/puppet-fdistdump-packages"

cd /tmp/build_area

dpkg-scanpackages ./ /dev/null | gzip > Packages.gz

ssh $FRONT "find ${REPO} -type f -delete"
scp *.deb Packages.gz ${FRONT}:${REPO}/
# >>> deb http://esb.metacentrum.cz/packages ./



