#!/usr/bin/env ruby

require 'json'
require 'open3'

def parse_nmap_output(stdout)
  result = {}
  lines = stdout.split("\n")
  current_ip_address = ""

  lines.each do |line|
    if line.include?('Nmap scan report for')
      current_ip_address = line.split(' ')[4]
      result[current_ip_address] = {}
    elsif (line.include?('open') || line.include?('filtered') || line.include?('closed')) && line.include?('/')
      split_line = line.split
      port_protocol = split_line[0].split('/')
      port = port_protocol[0].to_i
      protocol = port_protocol[1]
      state = split_line[1]
      service = split_line[2]

      result[current_ip_address][port] = {
        'state' => state,
        'protocol' => protocol,
        'service' => service
      }
    end
  end

  result
end

if ARGV.length != 1
  STDERR.puts "Please provide an IP address, range of IPs, or a domain as a command-line argument."
  exit 1
end

target = ARGV[0]
command = "nmap -p- #{target}"

stdout, stderr, status = Open3.capture3(command)

if status.exitstatus != 0
  STDERR.puts "exec error: #{stderr}"
  exit 1
end

open_ports = parse_nmap_output(stdout)
puts JSON.dump(open_ports)
