#!/usr/bin/env ruby

require 'json'
require 'cgi'

pattern = ARGV[0]

SCRIPT_DIR = File.dirname(__FILE__)

native_vpns = JSON.load(`#{File.join(SCRIPT_DIR, 'list-native-vpns.osascript')} 2>&1`)

completion_xml = <<-HERE
<?xml version="1.0"?>
<items>
HERE

native_vpns.each do |vpn|
  next if pattern && !vpn["name"].downcase.match(pattern.downcase)

  arg = {
    type: "native",
    id:   vpn["id"],
    state: vpn["connected"]
  }
  arg_string = JSON.generate(arg)
  verb = vpn["connected"] ? "Disconnect from" : "Connect to"
  completion_xml << <<-HERE
  <item uid="native:#{CGI.escapeHTML(vpn["id"])}" autocomplete="#{CGI.escapeHTML(vpn["name"])}">
    <arg>#{arg_string}</arg>
    <title>#{CGI.escapeHTML(vpn["name"])}</title>
    <subtitle>#{verb} #{CGI.escapeHTML(vpn["kind"])} VPN</subtitle>
  </item>
HERE
end

completion_xml << "</items>"

puts completion_xml
