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
	package { ["ipfixcol"]:
		ensure => installed,
		require => Apt::Source["securitycloud"],
	}

}
