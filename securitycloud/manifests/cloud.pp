# == Class: securitycloud::cloud
#
# Class will initialize SecurityCloud.git suite and preconfigure install.conf
# using informations from securitycloud.init discovery module.
#
# === Examples
#
#   class { "securitycloud::cloud": }
#
class securitycloud::cloud(
	$virtual_ip = undef,
) {


	# bootstrap config suite
	exec { "clone SecurityCloud.git":
		command => "/usr/bin/git clone https://github.com/CESNET/SecurityCloud.git /usr/local/SecurityCloud; /bin/chown root:root /usr/local/SecurityCloud; /bin/chmod g-s /usr/local/SecurityCloud",
		creates => "/usr/local/SecurityCloud/README.md",
	}


	# prepare install.conf
	$nodes_proxy = []
	$nodes_subcollector = securitycloud_discover_allnodes()
	if ( $virtual_ip ) {
		$virtual_ip_real = $virtual_ip
	} else {
		$virtual_ip_real = myexec("/usr/local/bin/securitycloud.init virtualip")
	}
	file { "/etc/ipfixcol/virtual_ip.conf":
		content => "${virtual_ip_real}\n",
		owner => "root", group => "root", mode => "0644",
	}
	file { "/usr/local/SecurityCloud/install/install.conf":
		content => template("${module_name}/usr/local/SecurityCloud/install/install.conf.erb"),
		owner => "root", group => "root", mode => "0644",
		require => Exec["clone SecurityCloud.git"],
	}



	file { "/etc/sysctl.d/ipfixcol-netbuffers.conf":
		source => "puppet:///modules/${module_name}/etc/sysctl.d/ipfixcol-netbuffers.conf",
		owner => "root", group => "root", mode => "0644",
		notify => Exec["sysctl read ipfixcol-netbuffers.conf"],
	}
	exec { "sysctl read ipfixcol-netbuffers.conf":
		command => "/sbin/sysctl --load=/etc/sysctl.d/ipfixcol-netbuffers.conf",
		refreshonly => true,
		require => File["/etc/sysctl.d/ipfixcol-netbuffers.conf"],
	}

}
