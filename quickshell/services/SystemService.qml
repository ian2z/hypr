pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower

Scope {
    id: root

    // =========================================================================
    // 1. BLUETOOTH (Quickshell.Bluetooth)
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

    readonly property var pairedBtDevices: {
        var list = []
        if (!Bluetooth.devices || !Bluetooth.devices.values) return list
        var devs = Bluetooth.devices.values
        for (var i = 0; i < devs.length; i++) {
            if (devs[i] && (devs[i].paired || devs[i].connected)) {
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
    // 2. REDE: WI-FI & CABEADA / ETHERNET (Quickshell.Networking + nmcli)
    // =========================================================================
    readonly property bool wifiEnabled: Networking.wifiEnabled
    property string netType: "none"       // "wifi", "ethernet", "none"
    property string netName: "Desconectado"
    property string netInterface: ""
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
        if (netType === "ethernet") return (netInterface || "Ethernet") + (tailscaleActive ? " • VPN" : "")
        if (netType === "wifi") return "Wi-Fi (" + wifiSignal + "%)" + (tailscaleActive ? " • VPN" : "")
        return wifiEnabled ? "Desconectado" : "Wi-Fi Desligado"
    }

    Process {
        id: netCheckProc
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION,DEVICE device 2>/dev/null; echo '---WIFI---'; nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes:' || true"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: (data) => {
                var text = data.trim()
                if (!text) return
                var parts = text.split("---WIFI---")
                var devLines = (parts[0] || "").trim().split("\n")
                var wifiLine = (parts[1] || "").trim()

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
        Quickshell.execDetached(["kitty", "-e", "yay"])
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
    // 5. BATERIA & PERFIL DE ENERGIA (UPower)
    // =========================================================================
    readonly property var displayBattery: UPower.displayDevice
    readonly property int batteryPercent: (displayBattery && displayBattery.ready)
        ? Math.round(displayBattery.percentage <= 1.0 ? displayBattery.percentage * 100 : displayBattery.percentage)
        : 100
    readonly property bool isCharging: !UPower.onBattery
    readonly property string batteryIcon: {
        if (isCharging) return ""
        if (batteryPercent >= 85) return ""
        if (batteryPercent >= 60) return ""
        if (batteryPercent >= 35) return ""
        if (batteryPercent >= 15) return ""
        return ""
    }

    // =========================================================================
    // TIMERS DE SINCRONIZAÇÃO
    // =========================================================================
    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!netCheckProc.running) netCheckProc.running = true
            if (!dndCheckProc.running) dndCheckProc.running = true
        }
    }

    Timer {
        interval: 1800000 // 30 min (igual ao intervalo de updates)
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshUpdates()
    }
}
