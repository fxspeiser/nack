import java.io.BufferedReader
import java.io.InputStreamReader
import kotlin.system.exitProcess

data class PortInfo(val state: String, val protocol: String, val service: String)

fun parseNmapOutput(stdout: String): Map<String, MutableMap<Int, PortInfo>> {
    val result = mutableMapOf<String, MutableMap<Int, PortInfo>>()
    val lines = stdout.lines()
    var currentIpAddress = ""

    for (line in lines) {
        if (line.contains("Nmap scan report for")) {
            currentIpAddress = line.split(" ")[4]
            result[currentIpAddress] = mutableMapOf()
        } else if (("open" in line || "filtered" in line || "closed" in line) && '/' in line) {
            val splitLine = line.split(" ")
            val portProtocol = splitLine[0].split('/')
            val port = portProtocol[0].toInt()
            val protocol = portProtocol[1]
            val state = splitLine[1]
            val service = splitLine[2]

            result[currentIpAddress]?.set(port, PortInfo(state, protocol, service))
        }
    }

    return result
}

fun main(args: Array<String>) {
    if (args.size != 1) {
        println("Please provide an IP address, range of IPs, or a domain as a command-line argument.")
        exitProcess(1)
    }

    val target = args[0]
    val command = "nmap -p- $target"

    val process = ProcessBuilder(command.split(" ")).redirectErrorStream(true).start()
    val stdout = BufferedReader(InputStreamReader(process.inputStream)).use(BufferedReader::readText)

    val exitCode = process.waitFor()

    if (exitCode != 0) {
        println("exec error: $stdout")
        exitProcess(1)
    }

    val openPorts = parseNmapOutput(stdout)
    println(openPorts)
}
