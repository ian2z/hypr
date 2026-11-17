import QtQuick
import QtQuick.Layouts
import Quickshell
import "../style"
import "../services"

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 8

    signal collapseRequested()

    // Perfil / Identificação
    Rectangle {
        Layout.preferredHeight: 34
        Layout.preferredWidth: profileRow.implicitWidth + 18
        radius: height / 2
        color: Theme.cardBackground
        border.color: Theme.borderSubtle
        border.width: 1

        RowLayout {
            id: profileRow
            anchors.centerIn: parent
            spacing: 7

            Text {
                text: ""
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.primary
            }

            Text {
                text: "ian"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: Theme.text
            }
        }
    }

    Item { Layout.fillWidth: true }

    // Uso de Hardware (CPU & RAM) - Clicar abre btop
    Rectangle {
        Layout.preferredHeight: 34
        Layout.preferredWidth: hwRow.implicitWidth + 18
        radius: height / 2
        color: hwMouse.containsMouse ? Theme.surface : Theme.cardBackground
        border.color: hwMouse.containsMouse ? Theme.primary : Theme.borderSubtle
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            id: hwRow
            anchors.centerIn: parent
            spacing: 10

            // CPU
            RowLayout {
                spacing: 4
                Text {
                    text: ""
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: SystemService.cpuPercent >= 85
                        ? Theme.red
                        : (SystemService.cpuPercent >= 70 ? Theme.orange : Theme.primary)
                }
                Text {
                    text: SystemService.cpuPercent + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.textMuted
                }
            }

            // Divisor sutil
            Rectangle {
                width: 1
                height: 14
                color: Theme.borderSubtle
            }

            // RAM
            RowLayout {
                spacing: 4
                Text {
                    text: "󰘚"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: SystemService.memPercent >= 90
                        ? Theme.red
                        : (SystemService.memPercent >= 80 ? Theme.orange : Theme.accent)
                }
                Text {
                    text: SystemService.memPercent + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.textMuted
                }
            }
        }

        MouseArea {
            id: hwMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                SystemService.openSystemMonitor()
                root.collapseRequested()
            }
        }
    }

    // Botão Bloquear Sessão (loginctl lock-session)
    Rectangle {
        Layout.preferredWidth: 34
        Layout.preferredHeight: 34
        radius: height / 2
        color: lockMouse.containsMouse ? Theme.surface : Theme.cardBackground
        border.color: lockMouse.containsMouse ? Theme.primary : Theme.borderSubtle
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: "󰌾"
            font.family: Theme.fontFamily
            font.pixelSize: 15
            color: lockMouse.containsMouse ? Theme.text : Theme.textMuted
        }

        MouseArea {
            id: lockMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Quickshell.execDetached(["loginctl", "lock-session"])
                root.collapseRequested()
            }
        }
    }

    // Botão Powermenu
    Rectangle {
        Layout.preferredWidth: 34
        Layout.preferredHeight: 34
        radius: height / 2
        color: powerMouse.containsMouse ? Theme.red : Theme.cardBackground
        border.color: powerMouse.containsMouse ? Theme.red : Theme.borderSubtle
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: "⏻"
            font.family: Theme.fontFamily
            font.pixelSize: 15
            color: powerMouse.containsMouse ? Theme.textOnPrimary : Theme.red
        }

        MouseArea {
            id: powerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                var home = Quickshell.env("HOME")
                Quickshell.execDetached([home + "/.config/quickshell/powermenu/toggle.sh"])
                root.collapseRequested()
            }
        }
    }

    // Botão Recolher Ilha
    Rectangle {
        Layout.preferredWidth: 34
        Layout.preferredHeight: 34
        radius: height / 2
        color: collapseMouse.containsMouse ? Theme.surfaceActive : Theme.cardBackground
        border.color: collapseMouse.containsMouse ? Theme.primary : Theme.borderSubtle
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: "󰅃"
            font.family: Theme.fontFamily
            font.pixelSize: 16
            color: collapseMouse.containsMouse ? Theme.primary : Theme.textMuted
        }

        MouseArea {
            id: collapseMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.collapseRequested()
        }
    }
}
