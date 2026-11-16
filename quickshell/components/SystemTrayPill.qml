import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../style"

Rectangle {
    id: trayRoot
    visible: SystemTray.items && SystemTray.items.values.length > 0
    implicitHeight: 36
    implicitWidth: trayRow.implicitWidth + 20
    radius: height / 2
    color: "#f20d0e15"
    border.color: "#36384d"
    border.width: 1
    clip: true

    Behavior on implicitWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutQuint }
    }

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: SystemTray.items ? SystemTray.items.values : []

            Item {
                id: itemDelegate
                required property var modelData
                width: 20
                height: 20

                QsMenuAnchor {
                    id: menuAnchor
                    anchor.item: itemDelegate
                    menu: (itemDelegate.modelData && itemDelegate.modelData.hasMenu) ? itemDelegate.modelData.menu : null
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 5
                    color: itemMouse.containsMouse ? Theme.surfaceActive : "transparent"

                    Image {
                        id: itemIcon
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: (itemDelegate.modelData && itemDelegate.modelData.icon) ? itemDelegate.modelData.icon : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: itemIcon.status !== Image.Ready
                        text: "󰅚"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.textSubtle
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                if (itemDelegate.modelData.onlyMenu && itemDelegate.modelData.hasMenu && itemDelegate.modelData.menu) {
                                    menuAnchor.open()
                                } else {
                                    itemDelegate.modelData.activate()
                                }
                            } else if (mouse.button === Qt.RightButton) {
                                if (itemDelegate.modelData.hasMenu && itemDelegate.modelData.menu) {
                                    menuAnchor.open()
                                } else {
                                    itemDelegate.modelData.secondaryActivate()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
