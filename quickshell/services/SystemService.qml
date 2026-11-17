pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking

Scope {
    id: root

    // =========================================================================
    // 1. REDE: WI-FI & CABEADA / ETHERNET (Detecção Dinâmica)
    // =========================================================================
    readonly property bool wifiEnabled: Networking.wifiEnabled
    property string netType: "none"       // "wifi", "ethernet", "none"
    property string netName: "Desconectado"
    property string netInterface: ""
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
        if (netType === "ethernet") return "Rede Cabeada"
        if (netType === "wifi") return netName !== "" ? netName : "Wi-Fi"
        return "Rede"
    }

    readonly property string netSubtitle: {
        if (netType === "ethernet") return (netInterface || "Ethernet") + (netIp ? " • " + netIp : "") + (tailscaleActive ? " • VPN" : "")
        if (netType === "wifi") return "Wi-Fi (" + wifiSignal + "%)" + (tailscaleActive ? " • VPN" : "")
        return wifiEnabled ? "Desconectado" : "Wi-Fi Desligado"
    }

    Process {
        id: netCheckProc
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION,DEVICE device 2>/dev/null; echo '---WIFI---'; nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes:' || true; echo '---IP---'; ip -4 -o addr show up scope global 2>/dev/null | awk '$2 !~ /^(docker|br-|veth|lo|tailscale)/ {split($4,a,\"/\"); print $2\":\"a[1]; exit}']"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: (data) => {
                var text = data.trim()
                if (!text) return
                var p1 = text.split("---WIFI---")
                var devLines = (p1[0] || "").trim().split("\n")
                var rest = p1[1] || ""
                var p2 = rest.split("---IP---")
                var wifiLine = (p2[0] || "").trim()
                var ipLine = (p2[1] || "").trim()

                var foundType = "none"
                var foundName = "Desconectado"
                var foundIface = ""
                var hasTailscale = false

                for (var i = 0; i < devLines.length; i++) {
                    var cols = devLines[i].split(":")
                    if (cols.length >= 4) {
                        var t = cols[0]
                        var st = cols[1]
                        var conn = cols[2]
                        var dev = cols[3]
                        if (t === "tun" && dev === "tailscale0" && st.indexOf("connected") !== -1) {
                            hasTailscale = true
                        } else if (t === "ethernet" && st === "connected") {
                            foundType = "ethernet"
                            foundName = conn || "Ethernet"
                            foundIface = dev
                        } else if (t === "wifi" && st === "connected" && foundType !== "ethernet") {
                            foundType = "wifi"
                            foundName = conn || "Wi-Fi"
                            foundIface = dev
                        }
                    }
                }

                if (wifiLine.indexOf("yes:") === 0) {
                    var wcols = wifiLine.split(":")
                    if (wcols.length >= 3) {
                        var sig = parseInt(wcols[wcols.length - 1], 10)
                        if (!isNaN(sig)) root.wifiSignal = sig
                    }
                }

                if (ipLine) {
                    var ipParts = ipLine.split(":")
                    if (ipParts.length >= 2) root.netIp = ipParts[1]
                }

                root.netType = foundType
                root.netName = foundName
                root.netInterface = foundIface
                root.tailscaleActive = hasTailscale
            }
        }
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled
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
        interval: 1200
        repeat: false
        onTriggered: netCheckProc.running = true
    }

    // =========================================================================
    // 2. BLUETOOTH (Quickshell.Bluetooth)
    // =========================================================================
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btEnabled: btAdapter ? btAdapter.enabled : false

    readonly property var connectedBtDevices: {
        var list = []
        if (!Bluetooth.devices || !Bluetooth.devices.values) return list
        var devs = Bluetooth.devices.values
        for (var i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].connected) {
                list.push(devs[i])
            }
        }
        return list
    }

    readonly property var primaryBtDevice: connectedBtDevices.length > 0 ? connectedBtDevices[0] : null
    readonly property string btStatusTitle: {
        if (!btEnabled) return "Bluetooth"
        if (primaryBtDevice) return primaryBtDevice.name || primaryBtDevice.deviceName || "Conectado"
        return "Bluetooth"
    }
    readonly property string btStatusSubtitle: {
        if (!btEnabled) return "Desligado"
        if (primaryBtDevice) {
            if (primaryBtDevice.batteryAvailable && primaryBtDevice.battery > 0) {
                var pct = primaryBtDevice.battery <= 1.0
                    ? Math.round(primaryBtDevice.battery * 100)
                    : Math.round(primaryBtDevice.battery)
                return "Conectado • " + pct + "%"
            }
            return "Conectado"
        }
        return "Ligado • Pareado"
    }

    function toggleBluetooth() {
        if (btAdapter) {
            btAdapter.enabled = !btAdapter.enabled
        } else {
            Quickshell.execDetached(["bluetoothctl", "power", btEnabled ? "off" : "on"])
        }
    }

    function openBluetoothManager() {
        Quickshell.execDetached(["kitty", "-e", "bluetoothctl"])
    }

    // =========================================================================
    // 3. FILTRO NOTURNO (Hyprsunset)
    // =========================================================================
    property bool sunsetActive: false
    property int sunsetPresetIndex: 0
    readonly property var sunsetPresets: [
        { temp: 4500, label: "4500K (Suave)" },
        { temp: 3500, label: "3500K (Médio)" },
        { temp: 2500, label: "2500K (Forte)" }
    ]
    readonly property int sunsetTemp: sunsetPresets[sunsetPresetIndex].temp
    readonly property string sunsetTempLabel: sunsetPresets[sunsetPresetIndex].label
    readonly property string sunsetIcon: sunsetActive ? "󰖔" : "󰖙"
    readonly property string sunsetTitle: "Luz Noturna"
    readonly property string sunsetSubtitle: sunsetActive ? sunsetTempLabel : "Desligada"

    Process {
        id: sunsetCheckProc
        command: ["pgrep", "-x", "hyprsunset"]
        onExited: (code, status) => {
            root.sunsetActive = (code === 0)
        }
    }

    function toggleSunset() {
        if (root.sunsetActive) {
            Quickshell.execDetached(["pkill", "-x", "hyprsunset"])
            root.sunsetActive = false
        } else {
            Quickshell.execDetached(["hyprsunset", "-t", String(root.sunsetTemp)])
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
    // 4. ATUALIZAÇÕES DO SISTEMA (checkupdates / yay)
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
                if (!isNaN(count)) root.pendingUpdates = count
            }
        }
    }

    function refreshUpdates() {
        if (!updatesProc.running) updatesProc.running = true
    }

    function runSystemUpdate() {
        Quickshell.execDetached(["kitty", "-e", "yay"])
    }

    // =========================================================================
    // 5. NÃO PERTURBE (Dunst)
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
    // 6. BATERIAS DO THINKPAD (BAT0, BAT1 e Total com Tempo Restante)
    // =========================================================================
    property int bat0Percent: 0
    property string bat0Status: ""
    property string bat0Time: ""

    property int bat1Percent: 0
    property string bat1Status: ""
    property string bat1Time: ""

    property int totalBatteryPercent: 0
    property string totalRemainingTime: ""
    property bool isCharging: false

    // Ícone dinâmico com degradação progressiva de 10 em 10%
    readonly property string batteryIcon: {
        if (isCharging) {
            if (totalBatteryPercent >= 90) return "󰂅"
            if (totalBatteryPercent >= 80) return "󰂋"
            if (totalBatteryPercent >= 70) return "󰂊"
            if (totalBatteryPercent >= 60) return "󰢞"
            if (totalBatteryPercent >= 50) return "󰂉"
            if (totalBatteryPercent >= 40) return "󰢝"
            if (totalBatteryPercent >= 30) return "󰂈"
            if (totalBatteryPercent >= 20) return "󰂇"
            if (totalBatteryPercent >= 10) return "󰂆"
            return "󰢜"
        }
        if (totalBatteryPercent >= 95) return "󰁹"
        if (totalBatteryPercent >= 90) return "󰂂"
        if (totalBatteryPercent >= 80) return "󰂁"
        if (totalBatteryPercent >= 70) return "󰂀"
        if (totalBatteryPercent >= 60) return "󰁿"
        if (totalBatteryPercent >= 50) return "󰁾"
        if (totalBatteryPercent >= 40) return "󰁽"
        if (totalBatteryPercent >= 30) return "󰁼"
        if (totalBatteryPercent >= 20) return "󰁻"
        if (totalBatteryPercent >= 10) return "󰁺"
        return "󰂃"
    }

    readonly property color batteryColor: {
        if (isCharging) return "#a6e3a1" // verde
        if (totalBatteryPercent <= 20) return "#f38ba8" // vermelho
        if (totalBatteryPercent <= 40) return "#fab387" // laranja
        return "#D4A373" // caramel
    }

    Process {
        id: batteryProc
        command: ["python3", Quickshell.shellDir + "/services/battery_info.py"]
        stdout: SplitParser {
            onRead: (data) => {
                var line = data.trim()
                if (line.indexOf("BAT|") === 0) {
                    var p = line.split("|")
                    root.bat0Percent = parseInt(p[1], 10) || 0
                    root.bat0Status = p[2] || ""
                    root.bat0Time = p[3] || ""

                    root.bat1Percent = parseInt(p[4], 10) || 0
                    root.bat1Status = p[5] || ""
                    root.bat1Time = p[6] || ""

                    root.totalRemainingTime = p[7] || ""
                    root.isCharging = (p[8] === "1")

                    var count = 0
                    var sum = 0
                    if (root.bat0Percent > 0) { sum += root.bat0Percent; count++; }
                    if (root.bat1Percent > 0) { sum += root.bat1Percent; count++; }
                    root.totalBatteryPercent = count > 0 ? Math.round(sum / count) : 0
                }
            }
        }
    }

    // =========================================================================
    // 7. HARDWARE (CPU, RAM) & UPTIME DO SISTEMA
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
            if (!batteryProc.running) batteryProc.running = true
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
