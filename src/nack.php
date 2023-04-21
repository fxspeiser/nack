<?php

function parse_nmap_output($stdout)
{
    $result = [];
    $lines = explode("\n", $stdout);
    $current_ip_address = "";

    foreach ($lines as $line) {
        if (strpos($line, 'Nmap scan report for') !== false) {
            $current_ip_address = explode(' ', $line)[4];
            $result[$current_ip_address] = [];
        } elseif ((strpos($line, 'open') !== false || strpos($line, 'filtered') !== false || strpos($line, 'closed') !== false) && strpos($line, '/') !== false) {
            $split_line = explode(' ', $line);
            $port_protocol = explode('/', $split_line[0]);
            $port = (int) $port_protocol[0];
            $protocol = $port_protocol[1];
            $state = $split_line[1];
            $service = $split_line[2];

            $result[$current_ip_address][$port] = [
                'state' => $state,
                'protocol' => $protocol,
                'service' => $service,
            ];
        }
    }

    return $result;
}

$argc = count($argv);

if ($argc !== 2) {
    fwrite(STDERR, "Please provide an IP address, range of IPs, or a domain as a command-line argument.\n");
    exit(1);
}

$target = $argv[1];
$command = "nmap -p- {$target}";

$descriptorspec = [
    0 => ["pipe", "r"],
    1 => ["pipe", "w"],
    2 => ["pipe", "w"],
];

$process = proc_open($command, $descriptorspec, $pipes);

if (is_resource($process)) {
    fclose($pipes[0]);
    $stdout = stream_get_contents($pipes[1]);
    fclose($pipes[1]);
    $stderr = stream_get_contents($pipes[2]);
    fclose($pipes[2]);

    $return_value = proc_close($process);

    if ($return_value !== 0) {
        fwrite(STDERR, "exec error: {$stderr}\n");
        exit(1);
    }

    $open_ports = parse_nmap_output($stdout);
    echo json_encode($open_ports) . PHP_EOL;
}
