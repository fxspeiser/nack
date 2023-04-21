#!/bin/bash

function parse_nmap_output() {
    local stdout="$1"
    local current_ip_address=""
    local result=""

    while read -r line; do
        if [[ "$line" == *"Nmap scan report for"* ]]; then
            current_ip_address=$(echo "$line" | awk '{print $5}')
            result="${result}${current_ip_address}: {"
        elif [[ "$line" == *"/"* && ( "$line" == *"open"* || "$line" == *"filtered"* || "$line" == *"closed"* ) ]]; then
            port_protocol=$(echo "$line" | awk '{print $1}')
            state=$(echo "$line" | awk '{print $2}')
            service=$(echo "$line" | awk '{print $3}')

            port=$(echo "$port_protocol" | awk -F'/' '{print $1}')
            protocol=$(echo "$port_protocol" | awk -F'/' '{print $2}')

            result="${result} ${port}: {state: \"${state}\", protocol: \"${protocol}\", service: \"${service}\"},"
        fi
    done <<< "$stdout"

    echo "{$result}"
}

if [ "$#" -ne 1 ]; then
    echo "Please provide an IP address, range of IPs, or a domain as a command-line argument."
    exit 1
fi

target="$1"
command="nmap -p- ${target}"

stdout=$(eval "$command" 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "exec error: $stdout"
    exit 1
fi

open_ports=$(parse_nmap_output "$stdout")
echo "$open_ports"
