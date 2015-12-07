#!/usr/bin/ruby

require 'logger'                
require 'syslog/logger'
require 'optparse'    

#http://www.rubydoc.info/list/gems/elasticsearch-api/class
require 'elasticsearch'
require 'rubygems'
require 'facter'
require 'pp'
require 'open3'


######################################################### init

class Interrupted < StandardError; end
#Thread.abort_on_exception=true
Thread.current["name"] = "distr_test_data"
$logger = Logger.new(STDOUT)
# DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
$logger.level = Logger::INFO
$options = {}
$options["esd_host"] = Facter.value("ipaddress")
$options["esd_port"] = 39200
$options["debug"] = false
OptionParser.new do |opts|
	opts.banner = "Usage: example.rb [options]"
	opts.on("-h", "--esd-host HOST", "esd host") do |v|		$options["esd_host"] = v end
	opts.on("-p", "--esd-port PORT", "esd port") do |v|		$options["esd_port"] = v.to_i end
	opts.on("-s", "--syslog", "log to syslog") do |v| 		$options["syslog"] = v end
	opts.on("-d", "--debug", "debug mode") do |v| 			$options["debug"] = v end
end.parse!
if $options["syslog"]
	$logger = Syslog::Logger.new(Thread.current["name"])
	$logger.level = Logger::INFO
	$logger.formatter = proc do |severity, datetime, progname, msg|
		"#{Logger::SEV_LABEL[severity]} #{Thread.current["name"]}: #{msg}\n"
	end
else
	$logger.formatter = proc do |severity, datetime, progname, msg|
		date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
		"[#{date_format}] #{severity} #{Thread.current["name"]}: #{msg}\n"
	end
end
if $options["debug"] then $logger.level = Logger::DEBUG end
#$logger.info("startup options #{$options}")


######################################################### lib
def as_size(s)
  units = %W(B KB MB GB TB)
  size, unit = units.reduce(s.to_f) do |(fsize, _), utype|
    #fsize > 512 ? [fsize / 1024, utype] : (break [fsize, utype])
    fsize > 500 ? [fsize / 1000, utype] : (break [fsize, utype])
  end
  "#{size > 9 || size.modulo(1) < 0.1 ? '%d' : '%.1f'}%s" % [size, unit]
end

#
# Returns stdout on success, false on failure, nil on error
#
def syscall1(*cmd)
  begin
    stdout, stderr, status = Open3.capture3(*cmd)
    status.success? && stdout.slice!(0..-(1 + $/.size)) # strip trailing eol
  rescue
  end
end


######################################################### main

client = Elasticsearch::Client.new(log: false, host: "#{$options["esd_host"]}:#{$options["esd_port"]}")
nodes = client.nodes.stats({metric: ["jvm", "os"]})
cluster_state = client.cluster.state

if $options["debug"]
	pp nodes
end
nodes["nodes"].each do |k,v|
	#puts "#{k} #{v}"
	if cluster_state["master_node"] == k then role = "master" else role = "data" end
	storage_size = syscall1("/usr/bin/ssh", "root@#{v["host"]}", "du -sh /opt/fdistdump/data | awk '{print $1}'")
	puts "#{k} #{v["host"]} #{v["name"]} #{v["transport_address"]} #{v["os"]["load_average"]} heap #{v["jvm"]["mem"]["heap_used_percent"]}%/#{as_size(v["jvm"]["mem"]["heap_max_in_bytes"])} #{role} storage #{storage_size}"
	
end

