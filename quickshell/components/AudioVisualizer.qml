import QtQuick
import QtQuick.Layouts
import "../style"

Item {
    id: root
    property bool active: false
    property int barCount: 18

    implicitHeight: 24
    Layout.fillWidth: true

    property real animPhase: 0.0
    Timer {
        interval: 55
        running: root.active && root.visible
        repeat: true
        onTriggered: {
            root.animPhase = (root.animPhase + 0.34) % (Math.PI * 2)
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

                readonly property real level: {
                    if (!root.active) return 0.14
                    var wave = Math.sin(root.animPhase + index * 0.65) * 0.28 +
                               Math.cos(root.animPhase * 1.4 - index * 0.42) * 0.22 +
                               Math.sin(root.animPhase * 2.1 + index * 1.1) * 0.12
                    return Math.min(0.95, Math.max(0.16, 0.48 + wave))
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.max(3, parent.width - 1)
                    height: Math.max(3, parent.height * parent.level)
                    radius: Theme.radiusSmall
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
