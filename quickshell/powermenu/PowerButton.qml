import QtQuick
import QtQuick.Layouts

Rectangle {
    id: btn
    property string icon: ""
    property string label: ""
    property string shortcut: ""
    property color accentColor: Theme.primary
    property bool isTriggered: false
    signal activated()

    implicitWidth: 96
    implicitHeight: 104
    radius: Theme.radiusMedium

    scale: {
        if (isTriggered) return 0.92
        if (mouseArea.pressed) return 0.95
        if (mouseArea.containsMouse) return 1.04
        return 1.0
    }

    color: {
        if (isTriggered) return btn.accentColor
        if (mouseArea.containsMouse) {
            return Qt.rgba(btn.accentColor.r, btn.accentColor.g, btn.accentColor.b, 0.18)
        }
        return Theme.cardBackground
    }

    border.color: {
        if (isTriggered || mouseArea.containsMouse) return btn.accentColor
        return Theme.borderSubtle
    }
    border.width: 1

    Behavior on scale {
        NumberAnimation { duration: 160; easing.type: Easing.OutBack }
    }
    Behavior on color {
        ColorAnimation { duration: 140 }
    }
    Behavior on border.color {
        ColorAnimation { duration: 140 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            btn.isTriggered = true
            btn.activated()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 7

        // Ícone da Ação
        Text {
            text: btn.icon
            font.family: Theme.fontFamily
            font.pixelSize: 26
            color: {
                if (btn.isTriggered) return Theme.textOnPrimary
                return mouseArea.containsMouse ? btn.accentColor : Theme.text
            }
            Layout.alignment: Qt.AlignHCenter

            Behavior on color { ColorAnimation { duration: 140 } }
        }

        // Título / Label
        Text {
            text: btn.label
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
            color: {
                if (btn.isTriggered) return Theme.textOnPrimary
                return mouseArea.containsMouse ? Theme.text : Theme.textMuted
            }
            Layout.alignment: Qt.AlignHCenter

            Behavior on color { ColorAnimation { duration: 140 } }
        }

        // Pílula com o Atalho de Teclado
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 18
            Layout.preferredWidth: keyText.implicitWidth + 12
            radius: height / 2
            color: {
                if (btn.isTriggered) return Qt.rgba(0, 0, 0, 0.3)
                if (mouseArea.containsMouse) {
                    return Qt.rgba(btn.accentColor.r, btn.accentColor.g, btn.accentColor.b, 0.25)
                }
                return Theme.surface
            }
            border.color: mouseArea.containsMouse ? btn.accentColor : Theme.borderSubtle
            border.width: 1

            Text {
                id: keyText
                anchors.centerIn: parent
                text: btn.shortcut
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                color: {
                    if (btn.isTriggered) return Theme.textOnPrimary
                    return mouseArea.containsMouse ? btn.accentColor : Theme.textSubtle
                }
            }
        }
    }
}
