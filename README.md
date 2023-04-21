# nack
Network portmap to JSON converter. **Use ethically and only on networks you own or for which you are responsible**. 
nack allows you to scan an IP address or a range of IP addresses for open ports and returns a JSON object containing the results.

## Requirements
1. supporting language for nack (nack.js requires Node.js, nack.py requires python ..) installed on your system. There is even an equivalent JSON return of your network ports from the bash shell.  
2. Nmap installed on your system

## Usage
1. Navigate to the script of your choice.
2. Open a terminal and navigate to the directory containing the script.
2. Run the script by providing an IP address, range of IPs, or a domain as a command-line argument:

`node .js <IP_address_or_domain>`

## Example
`node nmap_port_scanner.js <IP_address_or_domain>`

The script will output a JSON object containing the IP address, port number, state, protocol, and suspected service for each open port found. The JSON object will have a compacted version of the following structure:

`{
  "192.168.1.1": {
    "22": {
      "state": "open",
      "protocol": "tcp",
      "service": "ssh"
    },
    "3306": {
      "state": "open",
      "protocol": "tcp",
      "service": "mysql"
    }
  },
  "192.168.1.2": {
    "80": {
      "state": "open",
      "protocol": "tcp",
      "service": "http"
    },
    "6379": {
      "state": "open",
      "protocol": "tcp",
      "service": "redis"
    }
  }
}
`

##Important Note
This script is intended for network administrators to scan their own networks and servers for security purposes. Unauthorized scanning of networks you don't own or have permission to scan is illegal in many jurisdictions. Use this script responsibly and ethically.

##License
This script is provided under the MIT License. Please refer to the LICENSE file for more information.



