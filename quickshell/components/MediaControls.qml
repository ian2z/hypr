import QtQuick
import QtQuick.Layouts
import "../style"

Row {
    id: root
    property var player: null
    spacing: 12
    Layout.alignment: Qt.AlignHCenter

    // Previous Button
    Rectangle {
        width: 34
        height: 34
        radius: Theme.radiusSmall
        color: prevMouse.containsMouse ? Theme.surface : "transparent"
        border.width: prevMouse.containsMouse ? 1 : 0
        border.color: Theme.borderSubtle

        Text {
            anchors.centerIn: parent
            text: "󰒮"
            font.family: Theme.fontFamily
            font.pixelSize: 17
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
        width: 40
        height: 34
        radius: Theme.radiusSmall
        color: playMouse.containsMouse ? Theme.accent : Theme.primary

        Text {
            anchors.centerIn: parent
            text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
            font.family: Theme.fontFamily
            font.pixelSize: 18
            color: Theme.textOnPrimary
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

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    // Next Button
    Rectangle {
        width: 34
        height: 34
        radius: Theme.radiusSmall
        color: nextMouse.containsMouse ? Theme.surface : "transparent"
        border.width: nextMouse.containsMouse ? 1 : 0
        border.color: Theme.borderSubtle

        Text {
            anchors.centerIn: parent
            text: "󰒭"
            font.family: Theme.fontFamily
            font.pixelSize: 17
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
