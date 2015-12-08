# == Class: fdistdump::install
#
# Class will ensure installation of fdistdump binaries and basic cluster management scripts.
#
# === Examples
#
#   class { "fdistdump::install": }
#
class fdistdump::install() {

	#install
	file { "/etc/apt/apt.conf.d/99auth":       
		content => "APT::Get::AllowUnauthenticated yes;\n",
		owner => "root", group => "root", mode => "0644",
 	}
	if !defined(Class['apt']) { class { 'apt': } }
	apt::source { 'fdistdump':
	        location   => 'http://esb.metacentrum.cz/puppet-fdistdump-packages',
	        release => './',
	        repos => '',
		include_src => false,
		require => File["/etc/apt/apt.conf.d/99auth"],
	}

	package { ["fdistdump"]:
		ensure => installed,
		require => Apt::Source["fdistdump"],
	}

	#cluster coordination
	package {"ruby-nokogiri":
		ensure => installed,
	}
	class { "elk::esd": 
		cluster_name=>"fdd", 
		esd_heap_size=>"32M", 
	}
	file { "/usr/local/bin/cluster.init":
		ensure => link,
		target => "/puppet/fdistdump/bin/cluster.init",
	}

}
