# == Class: securitycloud::cluster
#
# TODO
#
# === Examples
#
#   class { "securitycloud::cluster": }
#
class securitycloud::cluster() {

	include securitycloud::install

	#cluster coordination
	package {"ruby-nokogiri":
		ensure => installed,
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
