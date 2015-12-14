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
	if !defined(Class['apt']) { class { 'apt': } }
	apt::source { 'securitycloud':
	        location   => 'http://esb.metacentrum.cz/puppet-securitycloud-packages/debian',
	        release => 'jessie',
	        repos => '',
	        key => 'B71FA8D5849604DB73C4608F88139C4C0811EDEA',
	        key_source => 'http://esb.metacentrum.cz/puppet-securitycloud-packages/securitycloud.asc',
		include_src => false,
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
