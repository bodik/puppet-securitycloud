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
	package { ["autoconf", "gcc", "make", "rake", "ruby-dev", "build-essential", "rpm"]: ensure => installed, }
	package { "fpm":
		ensure => installed,
		provider => gem,
	}

	#fdistdump
	package { ["libopenmpi-dev", "openmpi-bin", "openmpi-common", "openmpi-doc"]: ensure => installed }

}
