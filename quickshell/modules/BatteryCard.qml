import QtQuick
import QtQuick.Layouts
import "../style"
import "../services"

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: 64
    radius: Theme.radiusMedium
    color: Theme.cardBackground
    border.color: Theme.borderSubtle
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        // Ícone da Bateria em Círculo Destaque
        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 12
            color: Theme.surface
            border.color: Theme.borderSubtle
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: SystemService.batteryIcon
                font.family: Theme.fontFamily
                font.pixelSize: 18
                color: SystemService.batteryColor
            }
        }

        // Coluna Central: Porcentagem e Estimativa de Tempo
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                spacing: 6
                Text {
                    text: "Bateria"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.text
                }

                Text {
                    text: SystemService.totalBatteryPercent + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: SystemService.batteryColor
                }

                Text {
                    visible: SystemService.isCharging
                    text: "• Carregando"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.green
                }
            }

            Text {
                text: SystemService.totalRemainingTime !== ""
                    ? (SystemService.isCharging ? "Tempo até 100%: " + SystemService.totalRemainingTime : "Restante: " + SystemService.totalRemainingTime)
                    : (SystemService.isCharging ? "Carregador conectado" : "Em uso da bateria")
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textMuted
                elide: Text.ElideRight
            }
        }

        // Detalhamento ThinkPad Dual Battery (BAT0 / BAT1)
        RowLayout {
            spacing: 6
            visible: SystemService.bat0Percent > 0 && SystemService.bat1Percent > 0

            Rectangle {
                width: 1
                height: 28
                color: Theme.borderSubtle
            }

            ColumnLayout {
                spacing: 2

                RowLayout {
                    spacing: 4
                    Text {
                        text: "BAT 0:"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.textSubtle
                    }
                    Text {
                        text: SystemService.bat0Percent + "%" + (SystemService.bat0Time ? " (" + SystemService.bat0Time + ")" : "")
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.textMuted
                    }
                }

                RowLayout {
                    spacing: 4
                    Text {
                        text: "BAT 1:"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.textSubtle
                    }
                    Text {
                        text: SystemService.bat1Percent + "%" + (SystemService.bat1Time ? " (" + SystemService.bat1Time + ")" : "")
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.textMuted
                    }
                }
            }
        }
    }
}
