import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../style"

Item {
    id: root
    property bool active: false
    property int barCount: 18

    implicitHeight: 24
    Layout.fillWidth: true

    PwAudioSpectrum {
        id: spectrum
        node: Pipewire.defaultAudioSink
        enabled: root.active && root.visible
        bandCount: root.barCount
        frameRate: 30
        smoothing: true
        lowerCutoff: 40
        upperCutoff: 14000
    }

    // Fase de animação suave caso o stream de espectro não reporte picos altos
    property real animPhase: 0.0
    Timer {
        interval: 60
        running: root.active && root.visible
        repeat: true
        onTriggered: {
            root.animPhase = (root.animPhase + 0.32) % (Math.PI * 2)
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 3

        Repeater {
            model: root.barCount

            Item {
                required property int index
                Layout.fillWidth: true
                Layout.fillHeight: true

                readonly property real rawSpectrum: {
                    if (spectrum.values && index < spectrum.values.length) {
                        return spectrum.values[index]
                    }
                    return 0.0
                }

                readonly property real level: {
                    if (!root.active) return 0.12
                    if (rawSpectrum > 0.01) {
                        return Math.min(1.0, Math.max(0.15, Math.pow(rawSpectrum, 0.65) * 1.4))
                    }
                    // Movimento orgânico sutil enquanto toca
                    var wave = Math.sin(root.animPhase + index * 0.55) * 0.3 +
                               Math.cos(root.animPhase * 1.3 - index * 0.35) * 0.2
                    return Math.min(0.95, Math.max(0.18, 0.45 + wave))
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.max(3, parent.width - 1)
                    height: Math.max(3, parent.height * parent.level)
                    radius: 2
                    color: root.active
                        ? (index % 2 === 0 ? Theme.primary : Theme.accent)
                        : Theme.surface

                    Behavior on height {
                        NumberAnimation { duration: 65; easing.type: Easing.OutQuad }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }
        }
    }
}
