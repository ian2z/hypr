import QtQuick
import "../style"
import "../services"

Rectangle {
    id: batPillRoot
    implicitHeight: 36
    implicitWidth: 36
    radius: height / 2
    color: Theme.backgroundTransparent
    border.color: Theme.border
    border.width: 1
    clip: true

    Behavior on border.color {
        ColorAnimation { duration: 250 }
    }

    Text {
        anchors.centerIn: parent
        text: SystemService.batteryIcon
        font.family: Theme.fontFamily
        font.pixelSize: 15
        color: SystemService.batteryColor
    }
}
