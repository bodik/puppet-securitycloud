# == Class: fdistdump::dev
#
# Class will ensure installation of fdistdump build and packaging requirements
#
# === Examples
#
#   class { "fdistdump::dev": }
#
class fdistdump::dev() {

	#generic	
	package { ["autoconf", "gcc", "make", "rake", "ruby-dev", "build-essential", "rpm", "strace"]: ensure => installed, }
	package { "fpm":
		ensure => installed,
		provider => gem,
	}

	#fdistdump
	package { ["libopenmpi-dev", "openmpi-bin", "openmpi-common", "openmpi-doc"]: ensure => installed }

        #ipfixcol
	package { ["flex", "bison", "libxml2-dev", "libssl-dev", "pkg-config", "libsctp-dev", "xsltproc", "docbook-xsl", "doxygen", "libbz2-dev", "libpq-dev", "libgeoip-dev", "libsqlite3-dev"]: ensure => installed }

}
