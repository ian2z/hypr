import QtQuick
import QtQuick.Layouts
import "../style"

Row {
    id: root
    property var player: null
    spacing: 16
    Layout.alignment: Qt.AlignHCenter

    // Previous Button
    Rectangle {
        width: 36
        height: 36
        radius: width / 2
        color: prevMouse.containsMouse ? Theme.surface : "transparent"

        Text {
            anchors.centerIn: parent
            text: "󰒮"
            font.pixelSize: 18
            color: root.player && root.player.canGoPrevious ? Theme.text : Theme.textSubtle
        }

        MouseArea {
            id: prevMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.player && root.player.canGoPrevious) {
                    root.player.previous()
                }
            }
        }
    }

    // Play/Pause Button
    Rectangle {
        width: 44
        height: 44
        radius: width / 2
        color: Theme.primary

        Text {
            anchors.centerIn: parent
            text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
            font.pixelSize: 20
            color: Theme.background
        }

        MouseArea {
            id: playMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.player) {
                    root.player.togglePlaying()
                }
            }
        }

        scale: playMouse.containsMouse ? 1.08 : 1.0
        Behavior on scale { NumberAnimation { duration: 150 } }
    }

    // Next Button
    Rectangle {
        width: 36
        height: 36
        radius: width / 2
        color: nextMouse.containsMouse ? Theme.surface : "transparent"

        Text {
            anchors.centerIn: parent
            text: "󰒭"
            font.pixelSize: 18
            color: root.player && root.player.canGoNext ? Theme.text : Theme.textSubtle
        }

        MouseArea {
            id: nextMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.player && root.player.canGoNext) {
                    root.player.next()
                }
            }
        }
    }
}
