class fdistdump::install() {
	if !defined(Class['apt']) {
	        class { 'apt': }
	}
	apt::source { 'fdistdump':
	        location   => 'http://esb.metacentrum.cz/fdistdump-packages',
	        release => './',
	        repos => '',
	        require => Apt::Source["jenkins"],
	}

	package { ["openmpi-bin", "openmpi-common", "openmpi-doc", "libnf", "fdistdump"]:
		ensure => installed,
		require => Apt::Source["fdistdump"],
	}

	class { "elk::esd": 
		cluster_name=>"fdd", 
		esd_heap_size=>"32M", 
	}
}
