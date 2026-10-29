import QtQuick
import QtQuick.Layouts
import Quickshell
import "../style"
import "../services"

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    // Perfil / Identificação
    Rectangle {
        Layout.preferredHeight: 36
        Layout.preferredWidth: profileRow.implicitWidth + 18
        radius: Theme.radiusMedium
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
                font.pixelSize: 15
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
        Layout.preferredHeight: 36
        Layout.preferredWidth: hwRow.implicitWidth + 18
        radius: Theme.radiusMedium
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
                Qt.quit()
            }
        }
    }

    // Uptime do Sistema
    Rectangle {
        Layout.preferredHeight: 36
        Layout.preferredWidth: upRow.implicitWidth + 16
        radius: Theme.radiusMedium
        color: Theme.cardBackground
        border.color: Theme.borderSubtle
        border.width: 1

        RowLayout {
            id: upRow
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: "󰔛"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.primary
            }

            Text {
                text: SystemService.uptimeText
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                color: Theme.textMuted
            }
        }
    }

    // Botão Bloquear Sessão (loginctl lock-session)
    Rectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        radius: Theme.radiusMedium
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
                Qt.quit()
            }
        }
    }

    // Botão Powermenu (Quickshell Powermenu)
    Rectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        radius: Theme.radiusMedium
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
                Quickshell.execDetached(["sh", "-c", "sleep 0.08 && quickshell -p \"" + home + "/.config/quickshell/powermenu/shell.qml\""])
                Qt.quit()
            }
        }
    }
}
