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
	package { ["autoconf", "automake", "gcc", "libtool", "make", "rpm", "strace"]: ensure => installed, }
	case $::osfamily {
		'Debian': {
			package { ["build-essential", "rake", "ruby-dev"]: 
				ensure => installed,
				before => Package["fpm"],
			}
		}
		'RedHat': {
			package { ["rpm-build", "gcc-c++", "rubygem-rake", "ruby-devel"]: 
				ensure => installed, 
				before => Package["fpm"],
			}
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
			package { ["libbz2-dev", "libmpich-dev"]: ensure => installed, }
		}
		'RedHat': {
			package { ["bzip2-devel", "mpich-devel", "mpich-autoload"]: ensure => installed, }
		}
		default: { fail("\"${module_name}\" is probably not supported for OSfamily \"${::osfamily}\"") }
	}


        #ipfixcol-base
	package { ["bison", "flex", "doxygen"]: ensure => installed }
	case $::osfamily {
		'Debian': {
			package { ["pkg-config", "libssl-dev", "xsltproc", "libxml2-dev", "libxml2-utils", "libsctp-dev", "docbook-xsl", "corosync-dev"]: ensure => installed, }
		}
		'RedHat': {
			package { ["pkgconfig", "openssl-devel", "libxslt", "libxml2-devel", "lksctp-tools-devel", "docbook-style-xsl", "corosync-devel"]: ensure => installed, }
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
