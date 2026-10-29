import QtQuick
import QtQuick.Layouts

Rectangle {
    id: btn
    property string icon: ""
    property string label: ""
    property string shortcut: ""
    property color accentColor: Theme.gray1
    signal activated()

    color: mouseArea.containsMouse ? Qt.rgba(88/255, 91/255, 112/255, 0.35) : "transparent"
    border.color: mouseArea.containsMouse ? btn.accentColor : Theme.gray3
    border.width: 1
    radius: Theme.radius

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.activated()
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: btn.icon
            font.family: Theme.fontFamily
            font.pixelSize: 24
            color: mouseArea.containsMouse ? btn.accentColor : Theme.gray1
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: btn.label
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
            color: mouseArea.containsMouse ? Theme.ice : Theme.gray2
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "[" + btn.shortcut + "]"
            font.family: Theme.fontFamily
            font.pixelSize: 9
            color: mouseArea.containsMouse ? btn.accentColor : Theme.gray3
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
