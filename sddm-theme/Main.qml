import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#11111b"

    TextConstants { id: textConstants }

    // Palette definitions matching ecosystem
    readonly property color colorBase:      "#11111b"
    readonly property color colorSurface:   "#181825"
    readonly property color colorHover:     "#313244"
    readonly property color colorBorder:    "#585b70"
    readonly property color colorText:      "#cdd6f4"
    readonly property color colorMuted:     "#9399b2"
    readonly property color colorAccent:    "#89b4fa"
    readonly property color colorError:     "#f38ba8"
    readonly property color colorWarning:   "#fab387"
    readonly property color colorSuccess:   "#a6e3a1"
    readonly property string fontFamily:    "MesloLGS Nerd Font"

    property int sessionIndex: (typeof sessionModel !== "undefined" && sessionModel.lastIndex !== undefined) ? sessionModel.lastIndex : 0

    // Background Wallpaper
    Image {
        id: bgImage
        anchors.fill: parent
        source: Qt.resolvedUrl("background.jpg")
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // Subtle Dark Backdrop Tint
    Rectangle {
        anchors.fill: parent
        color: "#0b0b12"
        opacity: 0.45
    }

    // Live Clock in Top-Right
    Item {
        id: clockContainer
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        width: clockCol.implicitWidth
        height: clockCol.implicitHeight

        Column {
            id: clockCol
            spacing: 4
            anchors.right: parent.right

            Text {
                id: timeText
                color: colorText
                font.family: fontFamily
                font.pixelSize: 42
                font.bold: true
                anchors.right: parent.right

                function updateTime() {
                    var d = new Date();
                    timeText.text = Qt.formatDateTime(d, "HH:mm");
                    dateText.text = Qt.formatDateTime(d, "dddd, d MMMM yyyy");
                }
            }

            Text {
                id: dateText
                color: colorMuted
                font.family: fontFamily
                font.pixelSize: 14
                anchors.right: parent.right
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: timeText.updateTime()
            }
        }
    }

    // Center Login Card
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: 380
        height: Math.max(440, cardLayout.implicitHeight + 56)
        color: colorBase
        opacity: 0.94
        border.color: colorBorder
        border.width: 1
        radius: 0

        Column {
            id: cardLayout
            anchors.centerIn: parent
            width: parent.width - 56
            spacing: 20

            // Header: User Icon / Title
            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "reach for the stars"
                    color: colorAccent
                    font.family: fontFamily
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: colorBorder
            }

            // Username Field
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "USER"
                    color: colorMuted
                    font.family: fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                Rectangle {
                    id: userBox
                    width: parent.width
                    height: 38
                    color: colorSurface
                    border.color: userInput.activeFocus ? colorAccent : colorBorder
                    border.width: 1
                    radius: 0

                    TextInput {
                        id: userInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: colorText
                        font.family: fontFamily
                        font.pixelSize: 13
                        text: (typeof userModel !== "undefined" && userModel.lastUser) ? userModel.lastUser : ""
                        selectByMouse: true
                        clip: true

                        KeyNavigation.tab: passwordInput
                        KeyNavigation.backtab: powerReboot

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (passwordInput.text === "") {
                                    passwordInput.focus = true;
                                } else {
                                    sddm.login(userInput.text, passwordInput.text, root.sessionIndex);
                                }
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            // Password Field
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "PASSWORD"
                    color: colorMuted
                    font.family: fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                Rectangle {
                    id: passwordBox
                    width: parent.width
                    height: 38
                    color: colorSurface
                    border.color: passwordInput.activeFocus ? colorAccent : colorBorder
                    border.width: 1
                    radius: 0

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: colorText
                        font.family: fontFamily
                        font.pixelSize: 13
                        echoMode: TextInput.Password
                        selectByMouse: true
                        clip: true

                        KeyNavigation.tab: loginBtn
                        KeyNavigation.backtab: userInput

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(userInput.text, passwordInput.text, root.sessionIndex);
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            // Error Message Prompt
            Text {
                id: errorLabel
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: colorError
                font.family: fontFamily
                font.pixelSize: 11
                text: ""
                visible: text !== ""
                wrapMode: Text.WordWrap
            }

            // Login Button
            Rectangle {
                id: loginBtn
                width: parent.width
                height: 38
                color: loginMouse.containsMouse || activeFocus ? colorAccent : "#212234"
                border.color: colorAccent
                border.width: 1
                radius: 0

                KeyNavigation.tab: sessionSelector
                KeyNavigation.backtab: passwordInput

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        sddm.login(userInput.text, passwordInput.text, root.sessionIndex);
                        event.accepted = true;
                    }
                }

                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.login(userInput.text, passwordInput.text, root.sessionIndex)
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰌑"
                        color: loginMouse.containsMouse || loginBtn.activeFocus ? colorBase : colorAccent
                        font.family: fontFamily
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "LOGIN"
                        color: loginMouse.containsMouse || loginBtn.activeFocus ? colorBase : colorText
                        font.family: fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 1.5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Session Selector
            Rectangle {
                id: sessionSelector
                width: parent.width
                height: 30
                color: "transparent"
                border.color: sessionMouse.containsMouse || activeFocus ? colorAccent : colorBorder
                border.width: 1
                radius: 0

                KeyNavigation.tab: powerShutdown
                KeyNavigation.backtab: loginBtn

                function getSessionName() {
                    try {
                        if (typeof sessionModel !== "undefined" && sessionModel.count > 0 && root.sessionIndex < sessionModel.count) {
                            var item = sessionModel.data(sessionModel.index(root.sessionIndex, 0), Qt.UserRole + 4);
                            if (item) return item;
                            var obj = sessionModel.get(root.sessionIndex);
                            if (obj && obj.name) return obj.name;
                        }
                    } catch (e) {}
                    return "Hyprland";
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
                        if (typeof sessionModel !== "undefined" && sessionModel.count > 1) {
                            root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count;
                        }
                        event.accepted = true;
                    }
                }

                MouseArea {
                    id: sessionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof sessionModel !== "undefined" && sessionModel.count > 1) {
                            root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count;
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰍹"
                        color: colorAccent
                        font.family: fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: sessionNameText
                        text: sessionSelector.getSessionName()
                        color: colorMuted
                        font.family: fontFamily
                        font.pixelSize: 11
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Bottom Power Controls
            Row {
                id: powerRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                // Shutdown
                Rectangle {
                    id: powerShutdown
                    width: 44
                    height: 36
                    color: shutMouse.containsMouse || activeFocus ? "#f38ba8" : colorSurface
                    border.color: colorBorder
                    border.width: 1
                    radius: 0

                    KeyNavigation.tab: powerReboot
                    KeyNavigation.backtab: sessionSelector

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
                            sddm.powerOff();
                            event.accepted = true;
                        }
                    }

                    MouseArea {
                        id: shutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.powerOff()
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰐥"
                        color: shutMouse.containsMouse || powerShutdown.activeFocus ? colorBase : "#f38ba8"
                        font.family: fontFamily
                        font.pixelSize: 16
                    }
                }

                // Reboot
                Rectangle {
                    id: powerReboot
                    width: 44
                    height: 36
                    color: rebMouse.containsMouse || activeFocus ? "#fab387" : colorSurface
                    border.color: colorBorder
                    border.width: 1
                    radius: 0

                    KeyNavigation.tab: powerSuspend
                    KeyNavigation.backtab: powerShutdown

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
                            sddm.reboot();
                            event.accepted = true;
                        }
                    }

                    MouseArea {
                        id: rebMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.reboot()
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰜉"
                        color: rebMouse.containsMouse || powerReboot.activeFocus ? colorBase : "#fab387"
                        font.family: fontFamily
                        font.pixelSize: 16
                    }
                }

                // Suspend
                Rectangle {
                    id: powerSuspend
                    width: 44
                    height: 36
                    color: suspMouse.containsMouse || activeFocus ? "#89b4fa" : colorSurface
                    border.color: colorBorder
                    border.width: 1
                    radius: 0

                    KeyNavigation.tab: userInput
                    KeyNavigation.backtab: powerReboot

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
                            sddm.suspend();
                            event.accepted = true;
                        }
                    }

                    MouseArea {
                        id: suspMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.suspend()
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒲"
                        color: suspMouse.containsMouse || powerSuspend.activeFocus ? colorBase : "#89b4fa"
                        font.family: fontFamily
                        font.pixelSize: 16
                    }
                }
            }
        }
    }

    Connections {
        target: (typeof sddm !== "undefined") ? sddm : null
        function onLoginSucceeded() {
            errorLabel.color = colorSuccess;
            errorLabel.text = "Login successful!";
        }
        function onLoginFailed() {
            passwordInput.text = "";
            passwordInput.focus = true;
            errorLabel.color = colorError;
            errorLabel.text = "Authentication failed. Try again.";
        }
        function onInformationMessage(message) {
            errorLabel.color = colorAccent;
            errorLabel.text = message;
        }
    }

    Component.onCompleted: {
        if (userInput.text === "") {
            userInput.focus = true;
        } else {
            passwordInput.focus = true;
        }
    }
}
