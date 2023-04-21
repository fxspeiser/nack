# nack
Network portmap to JSON converter. Translate the detectable ports on a network to a JSON object. 
**Use ethically and only on networks you own or for which you are responsible**. 

nack allows you to scan an IP address or a range of IP addresses for open ports and returns a JSON object containing the results.

The general idea is that you can scan a network block or simgle address, and then work with the ports on that host in a familiar, JSON-compliant way. For instamce if you nack'd your localhost and had ssh open on the default port, you can use the output to do things like `localhost.22` in other things down the chain. 

## Requirements
1. supporting language for nack (nack.js requires Node.js, nack.py requires python ..) installed on your system. There is even an equivalent JSON return of your network ports from the bash shell.  
2. Nmap installed on your system

NOTE: root privileges are not required in most cases to use nack and most language ports work with the default installation of the language. As long as the system has nmap installed, it should be good to go. 

## Usage
1. Navigate to the script of your choice.
2. Open a terminal and navigate to the directory containing the script.
3. Run the script by providing an IP address, range of IPs, or a domain as a command-line argument:

`node nack.js <IP_address_or_domain>`

4. You can then save the output to a file or pipe it to use elsewhere. 

## Example
`node nack.js 127.0.0.1`

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



