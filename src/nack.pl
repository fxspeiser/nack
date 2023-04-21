#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use IPC::Open3;

sub parse_nmap_output {
    my ($stdout) = @_;
    my %result;
    my $current_ip_address;

    for my $line (split /\n/, $stdout) {
        if ($line =~ /Nmap scan report for/) {
            ($current_ip_address) = ($line =~ /Nmap scan report for (\S+)/);
            $result{$current_ip_address} = {};
        }
        elsif ($line =~ /(open|filtered|closed)/ && $line =~ /\//) {
            my ($port_protocol, $state, $service) = split /\s+/, $line;
            my ($port, $protocol) = split /\//, $port_protocol;
            $result{$current_ip_address}{$port} = {
                'state' => $state,
                'protocol' => $protocol,
                'service' => $service,
            };
        }
    }

    return \%result;
}

die "Please provide an IP address, range of IPs, or a domain as a command-line argument.\n" if @ARGV != 1;

my $target = $ARGV[0];
my $command = "nmap -p- $target";

my $pid = open3(my $stdin, my $stdout, my $stderr, $command);
waitpid($pid, 0);
my $exit_code = $? >> 8;

if ($exit_code != 0) {
    print "exec error: ", <$stderr>;
    exit 1;
}

my $open_ports = parse_nmap_output(join '', <$stdout>);
print to_json($open_ports);
