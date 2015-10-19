class fdistdump::build_packages() {
	
	#generic
	package { ["autoconf", "gcc", "make"]: ensure => installed, }

	#fdistdump
	package { ["libopenmpi-dev"]: ensure => installed }
	contain fdistdump::packages

}
