import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Scope {
    id: root

    property string uptimeStr: "󰔛  UPTIME: ..."

    function formatUptime(raw) {
        if (!raw) return "󰔛  UPTIME: N/A";
        var clean = raw.trim().replace(/^up\s+/i, "");
        var formatted = clean
            .replace(/\s*days?,\s*/gi, "d ")
            .replace(/\s*hours?,\s*/gi, "h ")
            .replace(/\s*minutes?/gi, "m")
            .replace(/\s*seconds?/gi, "s");
        return "󰔛  UPTIME: " + formatted;
    }

    Process {
        command: ["uptime", "-p"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.uptimeStr = root.formatUptime(this.text);
            }
        }
    }

    Process {
        id: cmdRunner
        property var pendingCmd: []
        command: pendingCmd
    }

    function runAction(cmdList) {
        cmdRunner.pendingCmd = cmdList;
        cmdRunner.running = true;
        closeTimer.start();
    }

    Timer {
        id: closeTimer
        interval: 150
        repeat: false
        onTriggered: Qt.quit()
    }

    PanelWindow {
        id: powermenuWindow
        visible: true
        focusable: true

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Dimmed backdrop
        Rectangle {
            anchors.fill: parent
            color: "#80000000"

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }
        }

        // Keyboard handler
        Item {
            focus: true
            Keys.onEscapePressed: Qt.quit()
            Keys.onPressed: event => {
                if (event.key === Qt.Key_1 || event.key === Qt.Key_D) {
                    root.runAction(["systemctl", "poweroff"]);
                } else if (event.key === Qt.Key_2 || event.key === Qt.Key_R) {
                    root.runAction(["systemctl", "reboot"]);
                } else if (event.key === Qt.Key_3 || event.key === Qt.Key_S) {
                    root.runAction(["systemctl", "suspend"]);
                } else if (event.key === Qt.Key_4 || event.key === Qt.Key_E) {
                    root.runAction(["hyprctl", "dispatch", "exit"]);
                } else if (event.key === Qt.Key_5 || event.key === Qt.Key_L) {
                    root.runAction(["loginctl", "lock-session"]);
                }
            }
        }

        // Centered Powermenu Dialog Card
        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 580
            height: 170
            color: Theme.black
            border.color: Theme.gray3
            border.width: 1
            radius: Theme.radius

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.uptimeStr
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.gray2
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "[ESC] CANCEL"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.gray3
                    }
                }

                // Divider line
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.gray3
                }

                // Actions Row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    PowerButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "⏻"
                        label: "Shutdown"
                        shortcut: "1"
                        accentColor: Theme.red
                        onActivated: root.runAction(["systemctl", "poweroff"])
                    }

                    PowerButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰜉"
                        label: "Reboot"
                        shortcut: "2"
                        accentColor: Theme.orange
                        onActivated: root.runAction(["systemctl", "reboot"])
                    }

                    PowerButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰒲"
                        label: "Suspend"
                        shortcut: "3"
                        accentColor: Theme.calm
                        onActivated: root.runAction(["systemctl", "suspend"])
                    }

                    PowerButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰍃"
                        label: "Log Out"
                        shortcut: "4"
                        accentColor: Theme.pacific
                        onActivated: root.runAction(["hyprctl", "dispatch", "exit"])
                    }

                    PowerButton {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        icon: "󰌾"
                        label: "Lock"
                        shortcut: "5"
                        accentColor: Theme.ice
                        onActivated: root.runAction(["loginctl", "lock-session"])
                    }
                }
            }
        }
    }
}
