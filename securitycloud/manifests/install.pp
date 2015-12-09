# == Class: securitycloud::install
#
# Class will ensure installation of fdistdump and ipfixcol binaries and basic cluster management scripts.
#
# === Examples
#
#   class { "securitycloud::install": }
#
class securitycloud::install() {

	#install
	file { "/etc/apt/apt.conf.d/99auth":       
		content => "APT::Get::AllowUnauthenticated yes;\n",
		owner => "root", group => "root", mode => "0644",
 	}
	if !defined(Class['apt']) { class { 'apt': } }
	apt::source { 'securitycloud':
	        location   => 'http://esb.metacentrum.cz/puppet-securitycloud-packages',
	        release => './',
	        repos => '',
		include_src => false,
		require => File["/etc/apt/apt.conf.d/99auth"],
	}

	package { ["fdistdump", "libnf"]:
		ensure => installed,
		require => Apt::Source["securitycloud"],
	}
	package { ["ipfixcol-base", "ipfixcol-plugins"]:
		ensure => installed,
		require => Apt::Source["securitycloud"],
	}


	#cluster coordination
	package {"ruby-nokogiri":
		ensure => installed,
	}
	class { "elk::esd": 
		cluster_name=>"sc", 
		esd_heap_size=>"32M", 
	}
	file { "/usr/local/bin/cluster.init":
		ensure => link,
		target => "/puppet/securitycloud/bin/cluster.init",
	}
}
