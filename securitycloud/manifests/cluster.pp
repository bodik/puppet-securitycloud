# == Class: securitycloud::cluster
#
# Class will ensure installation of SecurityCloud distributed test clustering suite.
#
# === Examples
#
#   class { "securitycloud::cluster": }
#
class securitycloud::cluster() {

	include securitycloud::install

	#cluster coordination
	case $::osfamily {
		'Debian': {
			package {"ruby-nokogiri": ensure => installed, }
		}
		'RedHat': {
			package {"rubygem-nokogiri": ensure => installed, }
		}
		default: {
			fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
		}
	}

	class { "elk::esd": 
		cluster_name=>"sc", 
		esd_heap_size=>"32M", 
	}
	file { "/usr/local/bin/securitycloud.init":
		ensure => link,
		target => "/puppet/securitycloud/bin/securitycloud.init",
	}

}
