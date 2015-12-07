#!/usr/bin/ruby.rb

require 'logger'                
require 'syslog/logger'
require 'optparse'    

#http://www.rubydoc.info/list/gems/elasticsearch-api/class
require 'elasticsearch'
require 'rubygems'
require 'facter'
require 'nokogiri'


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
$options["datasource"] = "http://esb.metacentrum.cz/puppet-fdistdump.git-testdata/"
$options["datastorage"] = "/opt/fdistdump/data"
$options["debug"] = false
OptionParser.new do |opts|
	opts.banner = "Usage: example.rb [options]"
	opts.on("-h", "--esd-host HOST", "esd host") do |v|	$options["esd_host"] = v end
	opts.on("-p", "--esd-port PORT", "esd port") do |v|	$options["esd_port"] = v.to_i end
	opts.on("-r", "--datasource URL", "data source") do |v|	$options["datasource"] = v end
	opts.on("-w", "--datastorage DIR", "data storage") do |v|	$options["datastorage"] = v end
	opts.on("-s", "--syslog", "log to syslog") do |v| $options["syslog"] = v end
	opts.on("-d", "--debug", "debug mode") do |v| $options["debug"] = v end
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
$logger.info("startup options #{$options}")



######################################################### main

me = Hash.new
nodes = nil
source_files = Array.new
storage_files = Array.new

unless File.directory?($options["datastorage"])
  FileUtils.mkdir_p($options["datastorage"])
end

client = Elasticsearch::Client.new(log: false, host: "#{$options["esd_host"]}:#{$options["esd_port"]}")
nodes = client.cluster.state["nodes"]

me["ipaddress"] = Facter.value('ipaddress')

nodes.each do |k,v| if v["transport_address"].start_with?("inet[/#{me["ipaddress"]}:") then me["node_name"] = k; break end end

me["nodes_index"] = nodes.keys.index(me["node_name"])

doc = Nokogiri::HTML(Faraday.get($options["datasource"]).body)
doc.xpath("//html/body/ul/li/a/@href").each do |x| if x.value.start_with?("nfcapd.") then source_files << x.value end end

Dir.glob("#{$options["datastorage"]}/*").select{ |e| if File.file?(e) then storage_files << File.basename(e) end }

me["my_data"] = Array.new
source_files.each_slice(nodes.length) do |x|
	if x.at(me["nodes_index"])
		me["my_data"] << x[me["nodes_index"]]
	end
end

$logger.info("nodes #{nodes.keys}")
$logger.info("me #{me}")
$logger.info("source_files #{source_files}")
$logger.info("storage_files #{storage_files}")

storage_files.each do |x|
	if not me["my_data"].include?(x)
		$logger.info("deleting #{x}")
		File.delete("#{$options["datastorage"]}/#{x}")
	end
end
me["my_data"].each do |x|
	if not storage_files.include?(x)
		$logger.info("downloading #{x}")
		system("/usr/bin/wget", "#{$options["datasource"]}/#{x}", "-O", "#{$options["datastorage"]}/#{x}")
	end
end

