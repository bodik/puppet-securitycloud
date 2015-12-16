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
	package { ["autoconf", "gcc", "make", "rpm", "strace"]: ensure => installed, }
	case $::osfamily {
		'Debian': {
			package { ["build-essential"]: ensure => installed, }
			package { ["rake", "ruby-dev"]: ensure => installed, }
		}
		'RedHat': {
			package { ["rpm-build", "automake"]: ensure => installed, }
			package { ["rubygem-rake", "ruby-devel"]: ensure => installed, }
		}
		default: { fail("\"${module_name}\" is probably not supported for OSfamily \"${::osfamily}\"") }
	}
	package { "fpm":
		ensure => installed,
		provider => gem,
	}


	#fdistdump
	case $::osfamily {
		'Debian': {
			package { ["libopenmpi-dev", "openmpi-bin", "openmpi-common", "openmpi-doc"]: ensure => installed, }
		}
		'RedHat': {
			package { ["openmpi", "openmpi-devel"]: ensure => installed, }
		}
		default: { fail("\"${module_name}\" is probably not supported for OSfamily \"${::osfamily}\"") }
	}


        #ipfixcol-base
	package { ["flex", "bison", "doxygen"]: ensure => installed }
	case $::osfamily {
		'Debian': {
			package { ["pkg-config", "libssl-dev", "xsltproc", "libxml2-dev", "libsctp-dev", "docbook-xsl"]: ensure => installed, }
		}
		'RedHat': {
			package { ["pkgconfig", "openssl-devel", "libxslt", "libxml2-devel", "lksctp-tools-devel", "docbook-style-xsl"]: ensure => installed, }
		}
		default: { fail("\"${module_name}\" is probably not supported for OSfamily \"${::osfamily}\"") }
	}


	#ipfixcol-plugins
	case $::osfamily {
		'Debian': {
			package { ["liblzo2-dev"]: ensure => installed }
		}
		'RedHat': {
			package { ["lzo-devel"]: ensure => installed }
		}
		default: { fail("\"${module_name}\" is probably not supported for OSfamily \"${::osfamily}\"") }
	}
	#package { ["libbz2-dev", "libpq-dev", "libgeoip-dev", "libsqlite3-dev"]: ensure => installed }
}
