# == Class: securitycloud::cloud
#
# Class will ensure installation of corosync, peacemaker, pcs and GlusterFS for SecurityCloud.
#
# === Examples
#
#   class { "securitycloud::cloud": }
#
class securitycloud::cloud() {

	# cloud infrastructure
	package { "corosync": ensure => installed, }
	package { "pcs": ensure => installed, }

	case $::osfamily {
		'Debian': {
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

}
