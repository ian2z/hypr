import QtQuick
import QtQuick.Layouts
import Quickshell
import "../style"
import "../services"

Rectangle {
    id: root
    property bool expanded: false

    Layout.fillWidth: true
    implicitHeight: mainCol.implicitHeight + 24
    radius: Theme.radiusMedium
    color: Theme.cardBackground
    border.color: Theme.borderSubtle
    border.width: 1

    Behavior on implicitHeight { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }

    ColumnLayout {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10

        // Linha Superior: Ícone do Dispositivo (Mute) + Nome do Dispositivo + % + Botões
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Botão de Ícone / Mute
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 10
                color: AudioService.muted
                    ? Theme.surface
                    : (muteMouse.containsMouse ? Theme.surfaceActive : Theme.primary)

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: AudioService.activeDeviceIcon
                    font.family: Theme.fontFamily
                    font.pixelSize: 17
                    color: AudioService.muted ? Theme.red : Theme.textOnPrimary
                }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AudioService.toggleMute()
                }
            }

            // Nome do dispositivo atual (Ex: TWS-6 ou Alto-falantes) + Categoria
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: AudioService.activeDeviceName
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.text
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: AudioService.muted
                        ? "Silenciado (" + AudioService.activeDeviceCategory + ")"
                        : AudioService.activeDeviceCategory
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: AudioService.muted ? Theme.red : Theme.primary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // Porcentagem de Volume
            Text {
                text: AudioService.volumePercent + "%"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: AudioService.muted ? Theme.textSubtle : Theme.textMuted
            }

            // Botão Expandir Lista de Dispositivos (Alto-falantes / Fone)
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 8
                color: expandMouse.containsMouse || root.expanded ? Theme.surface : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: root.expanded ? "󰅃" : "󰅀"
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: root.expanded ? Theme.primary : Theme.textMuted
                }

                MouseArea {
                    id: expandMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }
            }

            // Botão Abrir Pavucontrol
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 8
                color: mixerMouse.containsMouse ? Theme.surface : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰒓"
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: Theme.textMuted
                }

                MouseArea {
                    id: mixerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["pavucontrol"])
                }
            }
        }

        // Barra / Slider de Volume Interativo (Clique, Arraste e Scroll)
        Item {
            id: volumeSliderContainer
            Layout.fillWidth: true
            height: 18

            Rectangle {
                id: volumeTrack
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 8
                radius: 4
                color: Theme.surface

                Rectangle {
                    id: volumeFill
                    height: parent.height
                    radius: parent.radius
                    color: AudioService.muted ? Theme.textSubtle : Theme.primary
                    width: {
                        var clamped = Math.min(Math.max(AudioService.volume, 0.0), 1.0)
                        return clamped * volumeTrack.width
                    }

                    Behavior on width { NumberAnimation { duration: 60 } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                function updateVolFromMouse(mx) {
                    var ratio = Math.min(Math.max(mx / volumeTrack.width, 0.0), 1.0)
                    AudioService.setVolume(ratio)
                }

                onPressed: (mouse) => updateVolFromMouse(mouse.x)
                onPositionChanged: (mouse) => {
                    if (pressed) updateVolFromMouse(mouse.x)
                }
                onWheel: (wheel) => {
                    var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                    AudioService.setVolume(AudioService.volume + step)
                }
            }
        }

        // Lista Expansível de Dispositivos de Saída (Fone vs Alto-falantes)
        ColumnLayout {
            visible: root.expanded
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.borderSubtle
            }

            Text {
                text: "Dispositivos de Saída"
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                color: Theme.textSubtle
            }

            Repeater {
                model: AudioService.audioSinks

                Rectangle {
                    required property var modelData
                    readonly property bool isSelected: AudioService.defaultSink && modelData && (AudioService.defaultSink.id === modelData.id)
                    readonly property int nodeVolPct: (modelData && modelData.audio && !isNaN(modelData.audio.volume))
                        ? Math.round(modelData.audio.volume * 100)
                        : 0
                    readonly property bool nodeMuted: (modelData && modelData.audio) ? modelData.audio.muted : false

                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 8
                    color: sinkMouse.containsMouse
                        ? Theme.surfaceActive
                        : (isSelected ? Theme.surface : "transparent")
                    border.width: isSelected ? 1 : 0
                    border.color: Theme.primary

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: AudioService.sinkIcon(modelData, nodeMuted, nodeVolPct)
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            color: isSelected ? Theme.primary : Theme.textMuted
                        }

                        Text {
                            text: AudioService.sinkDisplayName(modelData)
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: isSelected
                            color: isSelected ? Theme.text : Theme.textMuted
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: nodeVolPct + "%"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: isSelected ? Theme.primary : Theme.textSubtle
                        }

                        Text {
                            visible: isSelected
                            text: "󰄬"
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.primary
                        }
                    }

                    MouseArea {
                        id: sinkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioService.selectSink(modelData)
                    }
                }
            }
        }
    }
}
