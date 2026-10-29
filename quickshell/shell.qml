import QtQuick
import QtQuick.Layouts
import Quickshell
import "style"
import "services"
import "modules"

Scope {
    id: root

    PanelWindow {
        id: controlCenterWindow
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

        // Camada invisível em tela cheia: clicar em qualquer lugar fora do painel fecha o Quickshell
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: Qt.quit()
        }

        // Atalho Esc também fecha o painel
        Item {
            focus: true
            Keys.onEscapePressed: Qt.quit()
        }

        // Card Flutuante do Painel de Controle (alinhado abaixo da Waybar de 30px)
        Rectangle {
            id: backgroundCard
            x: 8
            y: 38
            width: 420
            height: mainLayout.implicitHeight + 28

            radius: Theme.radiusLarge
            color: Theme.backgroundTransparent
            border.color: Theme.border
            border.width: 1

            Behavior on height {
                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
            }

            // Absorve cliques dentro do card para não disparar o fechamento do fundo
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                hoverEnabled: true
            }

            ColumnLayout {
                id: mainLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                // 1. Cabeçalho Geral (Usuário, Uptime, Bloqueio e Powermenu)
                HeaderBar {}

                // 2. Acessos Rápidos (Rede Cabeada, Hyprsunset, Updates, Não Perturbe)
                QuickSettingsGrid {}

                // 3. Controle de Volume Inteligente (Monitor / Fone + Microfone + Seletor de Saída)
                AudioPanel {}

                // 4. Player do Spotify / Mídia + Visualizador de Espectro em Tempo Real
                MediaCard {}
            }
        }
    }
}
