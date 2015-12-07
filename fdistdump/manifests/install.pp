class fdistdump::install() {

	file { "/etc/apt/apt.conf.d/99auth":       
		content => "APT::Get::AllowUnauthenticated yes;\n",
		owner => "root", group => "root", mode => "0644",
 	}
	if !defined(Class['apt']) { class { 'apt': } }
	apt::source { 'fdistdump':
	        location   => 'http://esb.metacentrum.cz/puppet-fdistdump-packages',
	        release => './',
	        repos => '',
		require => File["/etc/apt/apt.conf.d/99auth"],
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
