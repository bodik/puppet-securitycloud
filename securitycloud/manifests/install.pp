# == Class: securitycloud::install
#
# Class will ensure installation of fdistdump and ipfixcol binaries/packages from SecurityCloud repository.
#
# === Examples
#
#   class { "securitycloud::install": }
#
class securitycloud::install() {

	#repo, might be seaparate class
	case $::osfamily {
		'Debian': {
			if !defined(Class['apt']) { class { 'apt': } }
			apt::source { 'securitycloud':
			        location   => 'http://esb.metacentrum.cz/puppet-securitycloud-packages/debian',
			        release => 'jessie',
			        repos => 'main',
			        key => 'B71FA8D5849604DB73C4608F88139C4C0811EDEA',
			        key_source => 'http://esb.metacentrum.cz/puppet-securitycloud-packages/securitycloud.asc',
				include_src => false,

				before => Package["fdistdump", "libnf", "ipfixcol"],
			}
		}
		'RedHat': {
			yumrepo { 'securitycloud':
				descr    => 'securitycloud repo',
				baseurl  => "http://esb.metacentrum.cz/puppet-securitycloud-packages/redhat/centos7",
				gpgcheck => 1,
				gpgkey   => 'http://esb.metacentrum.cz/puppet-securitycloud-packages/securitycloud.asc',
				enabled  => 1,

				before => Package["fdistdump", "libnf", "ipfixcol"],
			}
		}
		default: {
			fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
		}
	}


	#install
	package { ["fdistdump", "libnf", "ipfixcol"]:
		ensure => installed,
	}
}
