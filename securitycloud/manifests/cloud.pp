# == Class: securitycloud::cloud
#
# Class will ensure installation of corosync, peacemaker, pcs and GlusterFS for SecurityCloud.
#
# === Examples
#
#   class { "securitycloud::cloud": }
#
class securitycloud::cloud(
	$virtual_ip = undef,
) {

	# cloud infrastructure packages
	package { "corosync": ensure => installed, }
	# TODO: there should be securitycloud package repo requirement, but it's installed through securitycloud::cluster
	package { "pcs": ensure => installed, }

	case $::osfamily {
		'Debian': {
		
			#pacemaker must come from jessie-backports
			if !defined(Class['apt']) { class { 'apt': } }
			apt::source { 'jessie-backports':
			        location   => 'http://http.debian.net/debian',
			        release => 'jessie-backports',
			        repos => 'main',
				include_src => false,

				before => Exec["install pacemaker jessie-backports"],
			}
			#package { "pacemaker": ensure => installed, }
			exec { "install pacemaker jessie-backports":
				command => "/usr/bin/apt-get install -y -t jessie-backports pacemaker",
				timeout => 600,
				unless => "/usr/bin/dpkg -l pacemaker",
			}

			package {"glusterfs-server": ensure => installed, }
			package {"libxml2-utils": ensure => installed, }

		}
		'RedHat': {
			package { "centos-release-gluster38": ensure => installed, }
			package { ["glusterfs-server", "glusterfs-resource-agents"]: 
				ensure => installed,
				require => Package["centos-release-gluster38"],
			}
			package { "pacemaker": ensure => installed, }
		}
		default: {
			fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
		}
	}



	# bootstrap config suite
	exec { "clone SecurityCloud.git":
		command => "/usr/bin/git clone https://github.com/CESNET/SecurityCloud.git /usr/local/SecurityCloud; /bin/chown root:root /usr/local/SecurityCloud; /bin/chmod g-s /usr/local/SecurityCloud",
		creates => "/usr/local/SecurityCloud/README.md",
	}
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
}
