import QtQuick
import QtQuick.Layouts
import Quickshell
import "../style"
import "../services"

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 10

    // Perfil / Identificação
    Rectangle {
        Layout.preferredHeight: 36
        Layout.preferredWidth: profileRow.implicitWidth + 20
        radius: Theme.radiusMedium
        color: Theme.cardBackground
        border.color: Theme.borderSubtle
        border.width: 1

        RowLayout {
            id: profileRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: ""
                font.family: Theme.fontFamily
                font.pixelSize: 15
                color: Theme.primary
            }

            Text {
                text: "ian"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                color: Theme.text
            }
        }
    }

    Item { Layout.fillWidth: true }

    // Status de Bateria (UPower)
    Rectangle {
        Layout.preferredHeight: 36
        Layout.preferredWidth: batRow.implicitWidth + 18
        radius: Theme.radiusMedium
        color: Theme.cardBackground
        border.color: Theme.borderSubtle
        border.width: 1

        RowLayout {
            id: batRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: SystemService.batteryIcon
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: SystemService.batteryPercent <= 20 && !SystemService.isCharging
                    ? Theme.red
                    : Theme.green
            }

            Text {
                text: SystemService.batteryPercent + "%"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: Theme.textMuted
            }
        }
    }

    // Botão Bloquear Sessão (Hyprlock / loginctl)
    Rectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        radius: Theme.radiusMedium
        color: lockMouse.containsMouse ? Theme.surface : Theme.cardBackground
        border.color: Theme.borderSubtle
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "󰌾"
            font.family: Theme.fontFamily
            font.pixelSize: 15
            color: Theme.textMuted
        }

        MouseArea {
            id: lockMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["loginctl", "lock-session"])
        }
    }

    // Botão Powermenu (Rofi)
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
                Quickshell.execDetached([home + "/.config/rofi/powermenu/type-1/powermenu.sh"])
            }
        }
    }
}
