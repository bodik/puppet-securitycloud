require "puppet"
module Puppet::Parser::Functions
	newfunction(:securitycloud_discover_allnodes, :type => :rvalue) do |args|
		out= Facter::Util::Resolution.exec('securitycloud.init allnodes')
		if out.nil?
			return :undef
		else
			return out.split(" ").sort()
		end
	end
end
