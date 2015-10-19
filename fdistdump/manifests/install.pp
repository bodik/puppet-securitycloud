class fdistdump::install() {

	package { ["openmpi-bin", "openmpi-common", "openmpi-doc"]:
		ensure => installed,
	}

        #this is actually install, but for now it's here
        contain metalib::avahi
        file { "/etc/avahi/services/fdistdump.service":
                source => "puppet:///modules/${module_name}/etc/avahi/fdistdump.service",
                owner => "root", group => "root", mode => "0644",
                require => Package["avahi-daemon"],
                notify => Service["avahi-daemon"],
        }

}
