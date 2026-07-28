import QtQuick
import "../style"

Item {
    id: root
    property string artUrl: ""
    property real size: 100

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        id: imageContainer
        anchors.fill: parent
        radius: Theme.radiusMedium
        color: Theme.surface
        clip: true

        Image {
            id: coverImage
            anchors.fill: parent
            source: root.artUrl !== "" ? root.artUrl : ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            smooth: true
            asynchronous: true
        }

        // Fallback icon when no cover is available
        Text {
            anchors.centerIn: parent
            text: ""
            font.pixelSize: root.size * 0.4
            font.family: "Nerd Font"
            color: Theme.primary
            visible: coverImage.status !== Image.Ready
        }
    }
}
