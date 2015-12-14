require "puppet"
module Puppet::Parser::Functions
	newfunction(:securitycloud_discover_collectors, :type => :rvalue) do |args|
		out= Facter::Util::Resolution.exec('securitycloud.init collectors')
		if out.nil?
			return :undef
		else
			return out.split(" ")
		end
	end
end
