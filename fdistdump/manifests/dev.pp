class fdistdump:dev() {
	
	package { ["autoconf", "gcc", "make", "rake", "ruby-dev", "build-essential", "rpm"]: ensure => installed, }
	package { "fpm":
		ensure => installed,
		provider => gem,
	}

	#fdistdump
	package { ["libopenmpi-dev"]: ensure => installed }

	contain fdistdump::install
}
