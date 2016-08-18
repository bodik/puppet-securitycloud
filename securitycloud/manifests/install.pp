# == Class: securitycloud::install
#
# Class will ensure installation of fdistdump and ipfixcol binaries/packages
# from SecurityCloud repository and also cloud infrastructure packages such as
# corosync, peacemaker, pcs and GlusterFS.
#
# === Examples
#
#   class { "securitycloud::install": }
#
class securitycloud::install() {

	# packages repository
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

				before => Package["fdistdump", "libnf", "ipfixcol", "pcs"],
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


	# main software 
	package { ["fdistdump", "libnf", "ipfixcol"]:
		ensure => installed,
	}




	# cloud infrastructure packages
	package { "corosync": ensure => installed, }
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
			package { "python34": ensure => installed, }
			service { "glusterd":
				enable => true,
				ensure => running,
			}
		}
		default: {
			fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
		}
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
