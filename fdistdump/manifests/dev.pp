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

        #ipfixcol-base
	package { ["flex", "bison", "xsltproc", "docbook-xsl", "doxygen", "libxml2-dev", "pkg-config", "libsctp-dev", "libssl-dev"]: ensure => installed }

	#ipfixcol-plugins
	#package { ["libbz2-dev", "libpq-dev", "libgeoip-dev", "libsqlite3-dev"]: ensure => installed }
}
