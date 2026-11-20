//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import "style"
import "services"
import "modules"
import "components"

Scope {
    id: root

    // 1. Reserva de Espaço Exclusivo no Topo
    PanelWindow {
        id: topReserveGap
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 32
        color: "transparent"
        exclusionMode: ExclusionMode.Auto
        mask: Region {} // 100% click-through
    }

    // 2. Handler IPC para controle remoto da Ilha (SUPER + O expande / recolhe suavemente)
    IpcHandler {
        target: "island"
        function toggle(): string {
            island.isExpanded = !island.isExpanded
            if (island.isExpanded) {
                island.showingHud = false
                island.showingNotification = false
            }
            return island.isExpanded ? "expanded" : "collapsed"
        }
    }

    // 3. Janela Principal da Dynamic Island (Overlay flutuante com entrada inteligente)
    PanelWindow {
        id: islandWindow
        visible: true
        focusable: true
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        // Mask de entrada inteligente:
        // - Compacto: Somente a Island e a cápsula do Tray recebem cliques. O resto da tela fica livre.
        // - Expandido: Clicar fora recolhe a Island de volta suavemente.
        mask: Region {
            item: island.isExpanded ? dismissArea : island
            regions: [
                Region {
                    item: (trayPill.visible && !island.isExpanded) ? trayPill : null
                }
            ]
        }

        // Área invisível de clique fora para fechar a expansão
        MouseArea {
            id: dismissArea
            anchors.fill: parent
            visible: island.isExpanded
            onClicked: island.isExpanded = false
        }

        // Tecla ESC recolhe a ilha se estiver expandida
        Item {
            focus: true
            Keys.onEscapePressed: {
                if (island.isExpanded) {
                    island.isExpanded = false
                }
            }
        }

        // Dynamic Island principal (Flutuando centralizada no gap superior)
        DynamicIsland {
            id: island
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 3
        }

        // Cápsula do System Tray acoplada ao lado direito da Island
        SystemTrayPill {
            id: trayPill
            anchors.left: island.right
            anchors.leftMargin: 8
            anchors.verticalCenter: island.verticalCenter
            visible: SystemTray.items && SystemTray.items.values.length > 0 && !island.isExpanded
        }
    }
}
