require "puppet"
module Puppet::Parser::Functions
	newfunction(:securitycloud_discover_myrole, :type => :rvalue) do |args|
		out= Facter::Util::Resolution.exec('cluster.init myrole')
		if out.nil?
			return :undef
		else
			return out
		end
	end
end
