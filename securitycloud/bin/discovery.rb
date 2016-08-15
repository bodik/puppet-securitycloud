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
$options["show_nodes"] = false
$options["myrole"] = false

OptionParser.new do |opts|
	opts.banner = "Usage: example.rb [options]"
	opts.on("-h", "--esd-host HOST", "esd host") do |v|		$options["esd_host"] = v end
	opts.on("-p", "--esd-port PORT", "esd port") do |v|		$options["esd_port"] = v.to_i end
	opts.on("-s", "--syslog", "log to syslog") do |v| 		$options["syslog"] = v end
	opts.on("-d", "--debug", "debug mode") do |v| 			$options["debug"] = v end

	opts.on("-q", "--query QUERY", "query disco -- myrole|proxy|collectors|allnodes|show[default]") do |v| 		$options["query"] = v end
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


def show_nodes()
	$nodes["nodes"].each do |k,v|
		#puts "#{k} #{v}"
		if $cluster_state["master_node"] == k then esrole = "master" else esrole = "data" end
		fstorage_size = syscall1("/usr/bin/ssh", "root@#{v["host"]}", "du -shL /scratch/fdistdump/data | awk '{print $1}'")
		fstorage_part = syscall1("/usr/bin/ssh", "root@#{v["host"]}", "df -h | grep '/scratch' | awk '{print $5\"/\"$2}'")
		gstorage_size = syscall1("/usr/bin/ssh", "root@#{v["host"]}", "if [ -d /data/flow/$(facter fqdn) ]; then du -shL /data/flow/$(facter fqdn) | awk '{print $1}'; else echo 0; fi")
		gstorage_part = syscall1("/usr/bin/ssh", "root@#{v["host"]}", "df -h | grep 'localhost:/flow' | awk '{print $5\"/\"$2}'")
		ipfixcol_running = syscall1("/usr/bin/ssh", "root@#{v["host"]}", "pidof ipfixcol")
		ipfixcol_vsz = syscall1("/usr/bin/ssh", "root@#{v["host"]}", "ps h -o vsz -p $(pidof ipfixcol)")
		if ipfixcol_running == false then irunning = "istopped" else irunning = "irunning" end
		if ipfixcol_vsz == false then ipfixcol_vsz = 0 end
		puts "#{k} #{v["host"]} #{v["name"]} #{v["transport_address"]} #{v["os"]["load_average"]} heap #{v["jvm"]["mem"]["heap_used_percent"]}%/#{as_size(v["jvm"]["mem"]["heap_max_in_bytes"])} #{esrole} fstor #{fstorage_size} #{fstorage_part} gstor #{gstorage_size} #{gstorage_part} procs #{irunning} vsz #{as_size(ipfixcol_vsz)}"
	end
end

def collectors()
	masterip = /inet\[\/(.*):[0-9]+\]/.match($nodes["nodes"][$cluster_state["master_node"]]["transport_address"])[1]
	collectors = []
	$nodes["nodes"].each do |k,v|
		tmpip = /inet\[\/(.*):[0-9]+\]/.match(v["transport_address"])[1]
		if ( tmpip != masterip )
			collectors << tmpip
		end
	end
	puts collectors.join(" ")
end

def proxy()
	masterip = /inet\[\/(.*):[0-9]+\]/.match($nodes["nodes"][$cluster_state["master_node"]]["transport_address"])[1]
	if masterip then puts masterip end
end

def allnodes()
	allnodes = []
	$nodes["nodes"].each do |k,v|
		allnodes << v["host"]
	end
	puts allnodes.join(" ")
end

def myrole()
	masterip = /inet\[\/(.*):[0-9]+\]/.match($nodes["nodes"][$cluster_state["master_node"]]["transport_address"])[1]
	if (Facter.value("ipaddress") == masterip)
		puts "proxy"
	else
		puts "collector"
	end
end

######################################################### main

$client = Elasticsearch::Client.new(log: false, host: "#{$options["esd_host"]}:#{$options["esd_port"]}")
$nodes = $client.nodes.stats({metric: ["jvm", "os"]})
$cluster_state = $client.cluster.state

case $options["query"]
	when "myrole"
		myrole()
	when "proxy"
		proxy()
	when "collectors"
		collectors()
  	when "allnodes"
		allnodes()
	else
		show_nodes()
end

