pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    // =========================================================================
    // 1. REDE CABEADA / ETHERNET (iproute2 + nmcli)
    // =========================================================================
    property string netType: "ethernet"   // "ethernet", "wifi", "none"
    property string netInterface: "enp6s0"
    property string netIp: ""
    property bool tailscaleActive: false

    readonly property string netIcon: {
        if (netType === "ethernet") return "󰈀"
        if (netType === "wifi") return "󰤨"
        return "󰈂"
    }

    readonly property string netTitle: {
        if (netType === "ethernet") return "Rede Cabeada"
        if (netType === "wifi") return "Wi-Fi"
        return "Desconectado"
    }

    readonly property string netSubtitle: {
        if (netType === "none") return "Sem conexão"
        var detail = netIp !== "" ? netIp : (netInterface || "Conectado")
        return detail + (tailscaleActive ? " • VPN" : "")
    }

    Process {
        id: netCheckProc
        command: ["sh", "-c", "IFACE_IP=$(ip -4 -o addr show up scope global 2>/dev/null | awk '$2 !~ /^(docker|br-|veth|lo|tailscale)/ {split($4,a,\"/\"); print $2\":\"a[1]; exit}'); IFACE=${IFACE_IP%%:*}; IP=${IFACE_IP#*:}; VPN=$(ip link show tailscale0 up 2>/dev/null | grep -q 'UP' && echo '1' || echo '0'); if [ -n \"$IFACE\" ]; then echo \"NET|ethernet|$IFACE|$IP|$VPN\"; else echo \"NET|none|||0\"; fi"]
        stdout: SplitParser {
            onRead: (data) => {
                var line = data.trim()
                if (line.indexOf("NET|") !== 0) return
                var parts = line.split("|")
                if (parts.length >= 5) {
                    root.netType = parts[1] || "none"
                    root.netInterface = parts[2] || ""
                    root.netIp = parts[3] || ""
                    root.tailscaleActive = (parts[4] === "1")
                }
            }
        }
    }

    function refreshNetwork() {
        if (!netCheckProc.running) {
            netCheckProc.running = true
        }
    }

    function openNetworkManager() {
        Quickshell.execDetached(["kitty", "-e", "nmtui"])
    }

    // =========================================================================
    // 2. FILTRO NOTURNO / LUZ AZUL (hyprsunset)
    // =========================================================================
    property bool sunsetActive: false
    readonly property var sunsetPresets: [4500, 3800, 3200]
    property int sunsetPresetIndex: 0
    readonly property int sunsetTemp: sunsetPresets[sunsetPresetIndex]

    readonly property string sunsetIcon: sunsetActive ? "󰖔" : "󰖙"
    readonly property string sunsetTitle: "Luz Noturna"
    readonly property string sunsetSubtitle: sunsetActive
        ? ("Ativo • " + sunsetTemp + "K")
        : ("Desligado • " + sunsetTemp + "K")

    Process {
        id: sunsetCheckProc
        command: ["sh", "-c", "pgrep -x hyprsunset >/dev/null 2>&1 && echo 'active' || echo 'inactive'"]
        stdout: SplitParser {
            onRead: (data) => {
                root.sunsetActive = (data.trim() === "active")
            }
        }
    }

    function toggleSunset() {
        if (root.sunsetActive) {
            Quickshell.execDetached(["pkill", "-x", "hyprsunset"])
            root.sunsetActive = false
        } else {
            Quickshell.execDetached(["sh", "-c", "pkill -x hyprsunset 2>/dev/null; hyprsunset -t " + root.sunsetTemp])
            root.sunsetActive = true
        }
    }

    function cycleSunsetTemp() {
        root.sunsetPresetIndex = (root.sunsetPresetIndex + 1) % root.sunsetPresets.length
        if (root.sunsetActive) {
            Quickshell.execDetached(["sh", "-c", "pkill -x hyprsunset 2>/dev/null; hyprsunset -t " + root.sunsetTemp])
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
