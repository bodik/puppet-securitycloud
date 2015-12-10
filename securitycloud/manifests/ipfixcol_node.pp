# == Class: securitycloud::ipfixcol_node
#
# Class will ensure installation of fdistdump and ipfixcol binaries, and configures node as needed.
#
# === Examples
#
#   class { "securitycloud:ipfixcol_node": }
#
class securitycloud::ipfixcol_node (
	$install_dir = "/usr/local/",

	$role = undef,
	$collectors = undef,
) {
	include securitycloud::install
	include securitycloud::cluster

	Class["securitycloud::ipfixcol_node"]->Class["securitycloud::cluster"]->Class["securitycloud::install"]

	if($role) {
		$role_real = $role
	} else {
		$role_real = securitycloud_discover_role()
	}
	case $role_real {
		#######################
		'proxy': {
			if($collectors) {
				$collectors_real = $collectors
			} else {
				$collectors_real = securitycloud_discover_collectors()
			}
			file { "${install_dir}/etc/ipfixcol/startup.xml":
				content => template("${module_name}/usr/local/etc/ipfixcol/proxy.xml.erb"),
				owner => "root", group => "root", mode => "0644",
				notify => Service["ipfixcol"],
			}
			notice("role ${role_real} with collectors at ${collectors}")
		}

		#######################
		'collector': { 
			file { "${install_dir}/etc/ipfixcol/startup.xml":
				content => template("${module_name}/usr/local/etc/ipfixcol/collector.xml.erb"),
				owner => "root", group => "root", mode => "0644",
				notify => Service["ipfixcol"],
			}
			notice("role ${role_real}")
		}

		#######################
  		default: { 
			warning("role unknown") 
		}
	}
	service { "ipfixcol":
		ensure => running,
		enable => true,
	}
}
