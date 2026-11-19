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
    property bool wifiEnabled: true
    property string netType: "none"       // "wifi", "ethernet", "none"
    property string netName: "Disconnected"
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
                    // NET|type|name|interface|ip|signal|tailscale|wifi_enabled
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
        interval: 1000
        repeat: false
        onTriggered: if (!netCheckProc.running) netCheckProc.running = true
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
        if (primaryBtDevice) return primaryBtDevice.name || primaryBtDevice.deviceName || "Connected"
        return "Bluetooth"
    }
    readonly property string btStatusSubtitle: {
        if (!btEnabled) return "Disabled"
        if (primaryBtDevice) {
            if (primaryBtDevice.batteryAvailable && primaryBtDevice.battery > 0) {
                var pct = primaryBtDevice.battery <= 1.0
                    ? Math.round(primaryBtDevice.battery * 100)
                    : Math.round(primaryBtDevice.battery)
                return "Connected • " + pct + "%"
            }
            return "Connected"
        }
        return "On • Paired"
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
    // 3. FILTRO NOTURNO (Hyprsunset Seguro)
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
        onTriggered: if (!sunsetCheckProc.running) sunsetCheckProc.running = true
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
    // 8. BRILHO DA TELA (brightnessctl)
    // =========================================================================
    property int brightnessPercent: 100
    signal brightnessChanged()

    readonly property string brightnessIcon: {
        if (brightnessPercent >= 75) return "󰃠"
        if (brightnessPercent >= 45) return "󰃟"
        if (brightnessPercent >= 15) return "󰃞"
        return "󰃝"
    }

    Process {
        id: brightnessCheckProc
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: (data) => {
                var line = data.trim()
                if (line) {
                    var parts = line.split(",")
                    if (parts.length >= 4) {
                        var pctStr = parts[3].replace("%", "").trim()
                        var pct = parseInt(pctStr, 10)
                        if (!isNaN(pct)) {
                            if (root.brightnessPercent !== pct) {
                                root.brightnessPercent = pct
                                root.brightnessChanged()
                            }
                        }
                    }
                }
            }
        }
    }

    function setBrightness(pct) {
        var clamped = Math.max(5, Math.min(100, Math.round(pct)))
        if (root.brightnessPercent !== clamped) {
            root.brightnessPercent = clamped
            root.brightnessChanged()
        }
        Quickshell.execDetached(["brightnessctl", "set", clamped + "%"])
    }

    function stepBrightness(delta) {
        setBrightness(root.brightnessPercent + delta)
    }

    function refreshBrightness() {
        if (!brightnessCheckProc.running) brightnessCheckProc.running = true
    }

    // =========================================================================
    // TIMERS DE SINCRONIZAÇÃO
    // =========================================================================
    Timer {
        interval: 2000
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
            if (!brightnessCheckProc.running) brightnessCheckProc.running = true
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
