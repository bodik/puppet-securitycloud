class fdistdump::packages() {

	packages { ["openmpi-bin", "openmpi-common", "openmpi-doc"]:
		ensure => installed,
	}

}
