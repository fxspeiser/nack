local json = require 'dkjson'

function parse_nmap_output(stdout)
    local result = {}
    local lines = {}
    for line in stdout:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    local current_ip_address = ""

    for _, line in ipairs(lines) do
        if string.find(line, "Nmap scan report for") then
            current_ip_address = string.match(line, "%S+%s+%S+%s+%S+%s+(%S+)")
            result[current_ip_address] = {}
        elseif (string.find(line, "open") or string.find(line, "filtered") or string.find(line, "closed")) and string.find(line, "/") then
            local split_line = {}
            for word in line:gmatch("%S+") do
                table.insert(split_line, word)
            end
            local port_protocol = {}
            for item in split_line[1]:gmatch("[^/]+") do
                table.insert(port_protocol, item)
            end
            local port = tonumber(port_protocol[1])
            local protocol = port_protocol[2]
            local state = split_line[2]
            local service = split_line[3]

            result[current_ip_address][port] = {
                state = state,
                protocol = protocol,
                service = service
            }
        end
    end

    return result
end

local args = {...}
if #args ~= 1 then
    print("Please provide an IP address, range of IPs, or a domain as a command-line argument.")
    os.exit(1)
end

local target = args[1]
local command = "nmap -p- " .. target

local process = io.popen(command, "r")
local stdout = process:read("*a")
process:close()

local open_ports = parse_nmap_output(stdout)
print(json.encode(open_ports, {indent = true}))
