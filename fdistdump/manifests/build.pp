class fdistdump::build() {
	contain fdistdump::build_packages

	exec { "build.sh":
		command => "/bin/sh /puppet/fdistdump/bin/build.sh",
		require => Class["fdistdump::build_packages"],
	}
}
