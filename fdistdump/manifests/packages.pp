class fdistdump::packages() {

	package { ["openmpi-bin", "openmpi-common", "openmpi-doc"]:
		ensure => installed,
	}

}
