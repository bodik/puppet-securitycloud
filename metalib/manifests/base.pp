# == Class: metalib::base
#
# Class for ensuring basic setting of managed machine such as: editors, git,
# puppet, hostname, krb5 client lib
#
# === Examples
#
# include metalib::base
#
class metalib::base {
	notice($name)

	# globals
	contain metalib::wget

	# generic debianization from next,next,next,... install
	package { ["nfs-common","rpcbind"]: ensure => absent, }
	package { ["joe","nano", "pico"]: ensure => absent, }
	package { ["mc", "git", "puppet", "screen", "psmisc"]: ensure => installed, }

	case $::osfamily {
		'Debian': {
			package { ["vim", "augeas-lenses", "nagios-plugins-basic"]: ensure => installed, }
			package { "krb5-user": ensure => installed, }
		}
		'RedHat': {
			package { ["vim-enhanced", "augeas-libs", "nagios-plugins-procs"]: ensure => installed, }
			package { "krb5-workstation": ensure => installed, }
		}
		default: {
			fail("\"${module_name}\" is probably not supported for OSfamily \"${::osfamily}\"")
		}
	}

	metalib::wget::download { "/etc/krb5.conf":
                uri => "https://download.zcu.cz/public/config/krb5/krb5.conf",
                owner => "root", group => "root", mode => "0644",
                timeout => 900;
	}

        file { "/etc/hosts":
                content => template("${module_name}/etc/hosts.erb"),
                owner => "root", group => "root", mode => "0644",
        }

	service { "puppet":
		ensure => stopped,
		enable => false,
	}
	file { "/etc/puppet/hiera.yaml":
		ensure => file,
	}
	file { "/usr/local/bin/pa.sh":
		ensure => link,
		target => "/puppet/metalib/bin/pa.sh",
	}
}
