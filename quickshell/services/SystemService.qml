pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    // =========================================================================
    // 1. REDE: WI-FI & CABEADA / ETHERNET (Detecção Dinâmica)
    // =========================================================================
    property bool wifiEnabled: true
    property string netType: "ethernet"   // "ethernet", "wifi", "none"
    property string netName: "Connected"
    property string netInterface: "enp6s0"
    property string netIp: ""
    property int wifiSignal: 0
    property bool tailscaleActive: false

    readonly property string netIcon: {
        if (netType === "ethernet") return "󰈀"
        if (netType === "wifi") {
            if (wifiSignal >= 75) return "󰤨"
            if (wifiSignal >= 50) return "󰤥"
            if (wifiSignal >= 25) return "󰤢"
            return "󰤟"
        }
        return wifiEnabled ? "󰤯" : "󰤭"
    }

    readonly property string netTitle: {
        if (netType === "ethernet") return "Wired Connection"
        if (netType === "wifi") return netName !== "" ? netName : "Wi-Fi"
        return "Network"
    }

    readonly property string netSubtitle: {
        if (netType === "ethernet") return (netInterface || "Ethernet") + (netIp ? " • " + netIp : "") + (tailscaleActive ? " • VPN" : "")
        if (netType === "wifi") return "Wi-Fi (" + wifiSignal + "%)" + (tailscaleActive ? " • VPN" : "")
        return wifiEnabled ? "Disconnected" : "Wi-Fi Off"
    }

    Process {
        id: netCheckProc
        command: ["python3", Quickshell.shellDir + "/services/network_info.py"]
        stdout: SplitParser {
            onRead: (data) => {
                var line = data.trim()
                if (line.indexOf("NET|") === 0) {
                    var p = line.split("|")
                    root.netType = p[1] || "none"
                    root.netName = p[2] || "Disconnected"
                    root.netInterface = p[3] || ""
                    root.netIp = p[4] || ""
                    root.wifiSignal = parseInt(p[5], 10) || 0
                    root.tailscaleActive = (p[6] === "1")
                    root.wifiEnabled = (p[7] === "1")
                }
            }
        }
    }

    function toggleWifi() {
        Quickshell.execDetached(["sh", "-c", "if nmcli radio wifi | grep -qi enabled; then nmcli radio wifi off; else nmcli radio wifi on; fi"])
        netRefreshDelay.restart()
    }

    function refreshNetwork() {
        if (!netCheckProc.running) netCheckProc.running = true
    }

    function openNetworkManager() {
        Quickshell.execDetached(["sh", "-c", "command -v networkmanager_dmenu >/dev/null 2>&1 && networkmanager_dmenu || kitty -e nmtui"])
    }

    Timer {
        id: netRefreshDelay
        interval: 400
        repeat: false
        onTriggered: root.refreshNetwork()
    }

    // =========================================================================
    // 2. FILTRO NOTURNO / LUZ AZUL (Hyprsunset Seguro)
    // =========================================================================
    property bool sunsetActive: false
    property int sunsetPresetIndex: 0
    readonly property var sunsetPresets: [
        { temp: 4500, label: "4500K (Soft)" },
        { temp: 3500, label: "3500K (Medium)" },
        { temp: 2500, label: "2500K (Warm)" }
    ]
    readonly property int sunsetTemp: sunsetPresets[sunsetPresetIndex].temp
    readonly property string sunsetTempLabel: sunsetPresets[sunsetPresetIndex].label
    readonly property string sunsetIcon: sunsetActive ? "󰖔" : "󰖙"
    readonly property string sunsetTitle: "Night Light"
    readonly property string sunsetSubtitle: sunsetActive ? sunsetTempLabel : "Off"

    Process {
        id: sunsetCheckProc
        command: [Quickshell.shellDir + "/services/sunset_control.sh", "status"]
        stdout: SplitParser {
            onRead: (data) => {
                root.sunsetActive = (data.trim() === "1")
            }
        }
    }

    function toggleSunset() {
        var script = Quickshell.shellDir + "/services/sunset_control.sh"
        Quickshell.execDetached([script, "toggle", String(root.sunsetTemp)])
        sunsetRefreshDelay.restart()
    }

    function cycleSunsetTemp() {
        root.sunsetPresetIndex = (root.sunsetPresetIndex + 1) % root.sunsetPresets.length
        if (root.sunsetActive) {
            var script = Quickshell.shellDir + "/services/sunset_control.sh"
            Quickshell.execDetached([script, "set", String(root.sunsetTemp)])
            sunsetRefreshDelay.restart()
        }
    }

    Timer {
        id: sunsetRefreshDelay
        interval: 350
        repeat: false
        onTriggered: {
            if (!sunsetCheckProc.running) sunsetCheckProc.running = true
        }
    }

    // =========================================================================
    // 3. ATUALIZAÇÕES DO SISTEMA (checkupdates / yay)
    // =========================================================================
    property int pendingUpdates: 0
    property bool checkingUpdates: false

    Process {
        id: updatesProc
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        onStarted: root.checkingUpdates = true
        onExited: root.checkingUpdates = false
        stdout: SplitParser {
            onRead: (data) => {
                var count = parseInt(data.trim(), 10)
                if (!isNaN(count)) {
                    root.pendingUpdates = count
                }
            }
        }
    }

    function refreshUpdates() {
        if (!updatesProc.running) {
            updatesProc.running = true
        }
    }

    function runSystemUpdate() {
        Quickshell.execDetached(["sh", "-c", "kitty -e yay"])
    }

    // =========================================================================
    // 4. NÃO PERTURBE / NOTIFICAÇÕES (Dunst)
    // =========================================================================
    property bool dndEnabled: false

    Process {
        id: dndCheckProc
        command: ["dunstctl", "is-paused"]
        stdout: SplitParser {
            onRead: (data) => {
                root.dndEnabled = (data.trim() === "true")
            }
        }
    }

    function toggleDnd() {
        Quickshell.execDetached(["dunstctl", "set-paused", "toggle"])
        root.dndEnabled = !root.dndEnabled
    }

    // =========================================================================
    // 5. HARDWARE (CPU, RAM) & UPTIME DO SISTEMA
    // =========================================================================
    property int cpuPercent: 0
    property real prevCpuTotal: 0
    property real prevCpuIdle: 0

    property int memPercent: 0
    property string memUsedGb: "0.0"
    property string memTotalGb: "0.0"

    property string uptimeText: "..."

    Process {
        id: hwCheckProc
        command: ["sh", "-c", "awk '/^cpu / {print \"CPU|\" ($2+$3+$4+$5+$6+$7+$8) \"|\" ($5+$6)}' /proc/stat; awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {if(t>0) printf \"MEM|%d|%.1f|%.1f\\n\", ((t-a)/t)*100, (t-a)/1048576, t/1048576}' /proc/meminfo"]
        stdout: SplitParser {
            onRead: (data) => {
                var line = data.trim()
                if (line.indexOf("CPU|") === 0) {
                    var cparts = line.split("|")
                    var total = parseFloat(cparts[1])
                    var idle = parseFloat(cparts[2])
                    if (root.prevCpuTotal > 0 && total > root.prevCpuTotal) {
                        var diffTotal = total - root.prevCpuTotal
                        var diffIdle = idle - root.prevCpuIdle
                        root.cpuPercent = Math.round(Math.max(0, Math.min(100, ((diffTotal - diffIdle) / diffTotal) * 100)))
                    }
                    root.prevCpuTotal = total
                    root.prevCpuIdle = idle
                } else if (line.indexOf("MEM|") === 0) {
                    var mparts = line.split("|")
                    root.memPercent = parseInt(mparts[1], 10) || 0
                    root.memUsedGb = mparts[2] || "0.0"
                    root.memTotalGb = mparts[3] || "0.0"
                }
            }
        }
    }

    Process {
        id: uptimeProc
        command: ["uptime", "-p"]
        stdout: SplitParser {
            onRead: (data) => {
                var raw = data.trim()
                if (!raw) return
                var clean = raw.replace(/^up\s+/i, "")
                    .replace(/\s*days?,\s*/gi, "d ")
                    .replace(/\s*days?\s*/gi, "d ")
                    .replace(/\s*hours?,\s*/gi, "h ")
                    .replace(/\s*hours?\s*/gi, "h ")
                    .replace(/\s*minutes?/gi, "m")
                root.uptimeText = clean || "0m"
            }
        }
    }

    function openSystemMonitor() {
        Quickshell.execDetached(["kitty", "-e", "btop"])
    }

    // =========================================================================
    // TIMERS DE SINCRONIZAÇÃO
    // =========================================================================
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!netCheckProc.running) netCheckProc.running = true
            if (!sunsetCheckProc.running) sunsetCheckProc.running = true
            if (!dndCheckProc.running) dndCheckProc.running = true
            if (!hwCheckProc.running) hwCheckProc.running = true
            if (!uptimeProc.running) uptimeProc.running = true
        }
    }

    Timer {
        interval: 1800000 // 30 min
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshUpdates()
    }
}
