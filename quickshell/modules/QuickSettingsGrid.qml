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

    // 1. Conexão de Rede Cabeada / Ethernet
    QuickTile {
        icon: SystemService.netIcon
        title: SystemService.netTitle
        subtitle: SystemService.netSubtitle
        active: SystemService.netType !== "none"
        hasSecondaryAction: true
        secondaryIcon: "󰅂"
        onClicked: SystemService.openNetworkManager()
        onSecondaryClicked: SystemService.refreshNetwork()
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

    // 3. Checagem de Atualizações (checkupdates / yay)
    QuickTile {
        icon: SystemService.checkingUpdates ? "󰑐" : "󰚰"
        title: "Atualizações"
        subtitle: {
            if (SystemService.checkingUpdates) return "Verificando..."
            if (SystemService.pendingUpdates > 0) return SystemService.pendingUpdates + " pacotes"
            return "Atualizado"
        }
        active: SystemService.pendingUpdates > 0
        activeColor: SystemService.pendingUpdates > 0 ? Theme.primary : Theme.green
        hasSecondaryAction: true
        secondaryIcon: "󰑐"
        onClicked: SystemService.runSystemUpdate()
        onSecondaryClicked: SystemService.refreshUpdates()
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
