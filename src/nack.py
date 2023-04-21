import sys
import subprocess
import re
import json

def parse_nmap_output(stdout):
    result = {}
    lines = stdout.split('\n')
    current_ip_address = ""

    for line in lines:
        if 'Nmap scan report for' in line:
            current_ip_address = line.split(' ')[4]
            result[current_ip_address] = {}
        elif ('open' in line or 'filtered' in line or 'closed' in line) and '/' in line:
            split_line = line.split()
            port_protocol = split_line[0].split('/')
            port = int(port_protocol[0])
            protocol = port_protocol[1]
            state = split_line[1]
            service = split_line[2]

            result[current_ip_address][port] = {
                'state': state,
                'protocol': protocol,
                'service': service,
            }

    return result

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Please provide an IP address, range of IPs, or a domain as a command-line argument.")
        sys.exit(1)

    target = sys.argv[1]
    command = f"nmap -p- {target}"

    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()

    if process.returncode != 0:
        print(f"exec error: {stderr.decode()}")
        sys.exit(1)

    open_ports = parse_nmap_output(stdout.decode())
    print(json.dumps(open_ports))
