# == Class: securitycloud::dev
#
# Class will ensure installation of fdistdump and ipfixcol build and packaging requirements.
#
# === Examples
#
#   class { "securitycloud::dev": }
#
class securitycloud::dev() {

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
	package { ["liblzo2-dev"]: ensure => installed }
	#package { ["libbz2-dev", "libpq-dev", "libgeoip-dev", "libsqlite3-dev"]: ensure => installed }
}
