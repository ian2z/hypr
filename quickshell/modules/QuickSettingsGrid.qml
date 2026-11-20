import QtQuick
import QtQuick.Layouts
import "../style"
import "../services"
import "../components"

GridLayout {
    id: root
    columns: 2
    rowSpacing: 8
    columnSpacing: 8
    Layout.fillWidth: true

    // 1. Conexão de Rede (Detecta Wi-Fi com SSID ou Cabeada Ethernet)
    QuickTile {
        icon: SystemService.netIcon
        title: SystemService.netTitle
        subtitle: SystemService.netSubtitle
        active: SystemService.netType !== "none"
        hasSecondaryAction: true
        secondaryIcon: "󰅂"
        onClicked: {
            if (SystemService.netType === "wifi" || SystemService.wifiEnabled) {
                SystemService.toggleWifi()
            } else {
                SystemService.openNetworkManager()
            }
        }
        onSecondaryClicked: SystemService.openNetworkManager()
    }

    // 2. Filtro Noturno (Hyprsunset - Luz Azul)
    QuickTile {
        icon: SystemService.sunsetIcon
        title: SystemService.sunsetTitle
        subtitle: SystemService.sunsetSubtitle
        active: SystemService.sunsetActive
        activeColor: Theme.orange
        hasSecondaryAction: true
        secondaryIcon: "󰔎"
        onClicked: SystemService.toggleSunset()
        onSecondaryClicked: SystemService.cycleSunsetTemp()
    }

    // 3. System Updates (checkupdates / yay)
    QuickTile {
        icon: SystemService.checkingUpdates ? "󰑐" : "󰚰"
        title: "Updates"
        subtitle: {
            if (SystemService.checkingUpdates) return "Checking..."
            if (SystemService.pendingUpdates > 0) {
                return SystemService.pendingUpdates + (SystemService.pendingUpdates === 1 ? " package" : " packages")
            }
            return "Up to date"
        }
        active: SystemService.pendingUpdates > 0
        activeColor: SystemService.pendingUpdates > 0 ? Theme.primary : Theme.green
        hasSecondaryAction: true
        secondaryIcon: "󰑐"
        onClicked: SystemService.runSystemUpdate()
        onSecondaryClicked: SystemService.refreshUpdates()
    }

    // 4. Do Not Disturb (Dunst Notifications)
    QuickTile {
        icon: SystemService.dndEnabled ? "󰂛" : "󰂚"
        title: "Notifications"
        subtitle: SystemService.dndEnabled ? "Do Not Disturb" : "Active"
        active: !SystemService.dndEnabled
        onClicked: SystemService.toggleDnd()
    }
}
