const { exec } = require("child_process");

// Retrieve target from the command line arguments
const target = process.argv[2];

if (!target) {
  console.error("Please provide an IP address, range of IPs, or a domain as a command-line argument.");
  process.exit(1);
}

// Run nmap command to scan for open ports
exec(`nmap -p- ${target}`, (error, stdout, stderr) => {
  if (error) {
    console.error(`exec error: ${error}`);
    return;
  }

  const openPorts = parseNmapOutput(stdout);
  console.log(JSON.stringify(openPorts));
});

interface PortInfo {
  state: string;
  protocol: string;
  service: string;
}

function parseNmapOutput(stdout: string): Record<string, Record<number, PortInfo>> {
  const result: Record<string, Record<number, PortInfo>> = {};
  const lines = stdout.split('\n');
  let currentIpAddress = "";

  lines.forEach(line => {
    if (line.includes('Nmap scan report for')) {
      currentIpAddress = line.split(' ')[4];
      result[currentIpAddress] = {};
    } else if (line.includes('open') || line.includes('filtered') || line.includes('closed')) {
      const splitLine = line.split(/\s+/);
      const portProtocol = splitLine[0].split('/');
      const port = parseInt(portProtocol[0], 10);
      const protocol = portProtocol[1];
      const state = splitLine[1];
      const service = splitLine[2];

      result[currentIpAddress][port] = {
        state: state,
        protocol: protocol,
        service: service,
      };
    }
  });

  return result;
}


module.exports = { parseNmapOutput };