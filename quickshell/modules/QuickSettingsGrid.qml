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

    // 2. Bluetooth (Mostra dispositivo conectado e bateria, ex: TWS-6)
    QuickTile {
        icon: SystemService.btEnabled
            ? (SystemService.primaryBtDevice ? "󰂱" : "")
            : "󰂲"
        title: SystemService.btStatusTitle
        subtitle: SystemService.btStatusSubtitle
        active: SystemService.btEnabled
        hasSecondaryAction: true
        secondaryIcon: "󰅂"
        onClicked: SystemService.toggleBluetooth()
        onSecondaryClicked: SystemService.openBluetoothManager()
    }

    // 3. Filtro Noturno (Hyprsunset)
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

    // 4. Modo Não Perturbe (Dunst Notifications)
    QuickTile {
        icon: SystemService.dndEnabled ? "󰂛" : "󰂚"
        title: "Notificações"
        subtitle: SystemService.dndEnabled ? "Silencioso" : "Ativas"
        active: !SystemService.dndEnabled
        onClicked: SystemService.toggleDnd()
    }
}
