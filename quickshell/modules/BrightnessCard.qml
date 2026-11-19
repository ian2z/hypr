import QtQuick
import QtQuick.Layouts
import Quickshell
import "../style"
import "../services"

Rectangle {
    id: root

    Layout.fillWidth: true
    implicitHeight: mainCol.implicitHeight + 24
    radius: Theme.radiusLarge
    color: Theme.cardBackground
    border.color: Theme.borderSubtle
    border.width: 1

    ColumnLayout {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10

        // Linha Superior: Ícone + Título/Subtítulo + Porcentagem + Botões Rápidos
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Botão de Ícone
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 12
                color: Theme.primary

                Text {
                    anchors.centerIn: parent
                    text: SystemService.brightnessIcon
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Theme.textOnPrimary
                }
            }

            // Descrição
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: "Display Brightness"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.text
                }

                Text {
                    text: "Internal Panel (eDP-1)"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.primary
                }
            }

            // Porcentagem Atual
            Text {
                text: SystemService.brightnessPercent + "%"
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                color: Theme.text
            }

            // Botão Diminuir Rápido (-10%)
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: height / 2
                color: decMouse.containsMouse ? Theme.surface : "transparent"
                border.color: decMouse.containsMouse ? Theme.borderSubtle : "transparent"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰃞"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.textMuted
                }

                MouseArea {
                    id: decMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SystemService.stepBrightness(-10)
                }
            }

            // Botão Aumentar Rápido (+10%)
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: height / 2
                color: incMouse.containsMouse ? Theme.surface : "transparent"
                border.color: incMouse.containsMouse ? Theme.borderSubtle : "transparent"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰃠"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.textMuted
                }

                MouseArea {
                    id: incMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SystemService.stepBrightness(10)
                }
            }
        }

        // Barra / Slider de Brilho Interativo (Clique, Arraste e Roda do Mouse)
        Item {
            id: sliderContainer
            Layout.fillWidth: true
            height: 18

            Rectangle {
                id: sliderTrack
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 8
                radius: height / 2
                color: Theme.surface

                Rectangle {
                    id: sliderFill
                    height: parent.height
                    radius: height / 2
                    color: Theme.primary
                    width: {
                        var pct = Math.min(Math.max(SystemService.brightnessPercent / 100.0, 0.05), 1.0)
                        return pct * sliderTrack.width
                    }

                    Behavior on width {
                        NumberAnimation { duration: 60 }
                    }
                }
            }

            MouseArea {
                id: sliderMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updateFromPos(mouseX) {
                    var norm = Math.max(0.05, Math.min(1.0, mouseX / width))
                    SystemService.setBrightness(norm * 100)
                }

                onPressed: (mouse) => updateFromPos(mouse.x)
                onPositionChanged: (mouse) => {
                    if (pressed) updateFromPos(mouse.x)
                }
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) {
                        SystemService.stepBrightness(5)
                    } else if (wheel.angleDelta.y < 0) {
                        SystemService.stepBrightness(-5)
                    }
                }
            }
        }
    }
}
