package ignite.api2

import std.collection.ArrayList
import std.process.executeWithOutput
import std.fs.{File, exists}
import std.regex.Regex
import std.net.{UdpSocket, IPSocketAddress}

/// Device network info: local IP list, default gateway, DNS server list.
public struct NetworkInfo {
    public let ips: Array<String>
    public let gateway: ?String
    public let dns: Array<String>

    public init(ips: Array<String>, gateway: ?String, dns: Array<String>) {
        this.ips = ips
        this.gateway = gateway
        this.dns = dns
    }
}

// ── Kernel-level get local IP: UDP connect + localAddress, no external commands ──

/// Get "local IP for accessing the internet" via UDP socket connect, no external commands, cross-platform.
public func getPreferredLocalIP(): ?String {
    try {
        let sock = UdpSocket(bindAt: 0)
        sock.bind()
        sock.connect(IPSocketAddress.parse("8.8.8.8:53"))
        let local = sock.localAddress
        sock.close()
        match (local) {
            case sa: IPSocketAddress =>
                let addr = sa.address
                if (addr.isLoopback()) { None } else { Some(addr.toString()) }
            case _ => None
        }
    } catch (_: Exception) {
        None
    }
}

// ── Miiltiplatform：ips main UDP，fallback to command parsing ──

@When[os == "Windows"]
public func getNetworkInfo(): NetworkInfo {
    var ips = ArrayList<String>()
    if (let Some(ip) <- getPreferredLocalIP()) {
        ips.add(ip)
    }
    let (_, stdout, _) = executeWithOutput("cmd", ["/C", "ipconfig", "/all"])
    let text = String.fromUtf8(stdout)
    if (ips.size == 0) {
        for (s in parseIPv4s(text)) { ips.add(s) }
    }
    let gateway = parseWindowsGateway(text)
    let dnsList = parseWindowsDns(text)
    NetworkInfo(ips.toArray(), gateway, dnsList)
}

@When[os == "Linux"]
public func getNetworkInfo(): NetworkInfo {
    var ips = ArrayList<String>()
    if (let Some(ip) <- getPreferredLocalIP()) {
        ips.add(ip)
    }
    if (ips.size == 0) {
        let (code, stdout, _) = executeWithOutput("ip", ["-4", "addr", "show"])
        if (code == 0) {
            let text = String.fromUtf8(stdout)
            for (s in parseIPv4s(text)) { ips.add(s) }
        }
    }
    var gateway: ?String = None
    let (code2, out2, _) = executeWithOutput("ip", ["route", "show", "default"])
    if (code2 == 0) {
        gateway = parseLinuxGateway(String.fromUtf8(out2))
    }
    let dnsList = readResolvConf("/etc/resolv.conf")
    NetworkInfo(ips.toArray(), gateway, dnsList)
}

@When[os == "macOS"]
public func getNetworkInfo(): NetworkInfo {
    var ips = ArrayList<String>()
    if (let Some(ip) <- getPreferredLocalIP()) {
        ips.add(ip)
    }
    if (ips.size == 0) {
        let (code, stdout, _) = executeWithOutput("ifconfig", [])
        if (code == 0) {
            let text = String.fromUtf8(stdout)
            for (s in parseIPv4s(text)) { ips.add(s) }
        }
    }
    var gateway: ?String = None
    let (code2, out2, _) = executeWithOutput("route", ["-n", "get", "default"])
    if (code2 == 0) {
        gateway = parseMacOsGateway(String.fromUtf8(out2))
    }
    let dnsList = readResolvConf("/etc/resolv.conf")
    NetworkInfo(ips.toArray(), gateway, dnsList)
}

// ── Generic parsing: IPv4, resolv.conf ──

func parseIPv4s(text: String): Array<String> {
    let re = Regex(#"\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b"#)
    let matches = re.findAll(text)
    var list = ArrayList<String>()
    var seen = ArrayList<String>()
    for (md in matches) {
        let s = md.matchString()
        if (s == "127.0.0.1") { continue }
        var found = false
        for (x in seen) {
            if (x == s) { found = true; break }
        }
        if (!found) {
            seen.add(s)
            list.add(s)
        }
    }
    list.toArray()
}

func readResolvConf(path: String): Array<String> {
    if (!exists(path)) { return [] }
    try {
        let bytes = File.readFrom(path)
        let text = String.fromUtf8(bytes)
        var list = ArrayList<String>()
        let re = Regex(#"nameserver\s+(\S+)"#)
        let matches = re.findAll(text, group: true)
        for (md in matches) {
            if (md.groupCount() >= 1) {
                let s = md.matchString(1)
                if (s.size > 0) { list.add(s) }
            }
        }
        list.toArray()
    } catch (_: Exception) {
        []
    }
}

// ── Windows: ipconfig /all 输出解析 ──

func parseWindowsGateway(text: String): ?String {
    // "默认网关" 或 "Default Gateway" 行后跟 IP
    let re = Regex(#"(?i)(?:Default Gateway|默认网关)[\s.:]+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"#)
    let arr = re.findAll(text, group: true)
    if (arr.size > 0 && arr[0].groupCount() >= 1) {
        let s = arr[0].matchString(1)
        if (s.size > 0) { return Some(s) }
    }
    None
}

func parseWindowsDns(text: String): Array<String> {
    let re = Regex(#"(?i)(?:DNS Servers|DNS 服务器)[\s.:]+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"#)
    let arr = re.findAll(text, group: true)
    var list = ArrayList<String>()
    for (md in arr) {
        if (md.groupCount() >= 1) {
            let s = md.matchString(1)
            if (s.size > 0) { list.add(s) }
        }
    }
    list.toArray()
}

// ── Linux: ip route show default → "default via 192.168.1.1 ..." ──

func parseLinuxGateway(text: String): ?String {
    let re = Regex(#"default\s+via\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"#)
    let arr = re.findAll(text, group: true)
    if (arr.size > 0 && arr[0].groupCount() >= 1) {
        let s = arr[0].matchString(1)
        if (s.size > 0) { return Some(s) }
    }
    None
}

// ── macOS: route -n get default → "gateway: 192.168.1.1" ──

func parseMacOsGateway(text: String): ?String {
    let re = Regex(#"gateway:\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"#)
    let arr = re.findAll(text, group: true)
    if (arr.size > 0 && arr[0].groupCount() >= 1) {
        let s = arr[0].matchString(1)
        if (s.size > 0) { return Some(s) }
    }
    None
}
