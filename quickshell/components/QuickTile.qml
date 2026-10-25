import QtQuick
import QtQuick.Layouts
import "../style"

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool hasSecondaryAction: false
    property string secondaryIcon: "󰅂"
    property color activeColor: Theme.primary

    signal clicked()
    signal secondaryClicked()

    Layout.fillWidth: true
    implicitHeight: 58
    radius: Theme.radiusMedium

    color: {
        if (mainMouse.containsMouse) return Theme.surfaceActive
        return root.active ? Theme.surface : Theme.cardBackground
    }

    border.width: 1
    border.color: root.active ? root.activeColor : Theme.borderSubtle

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 10

        // Círculo do Ícone
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 10
            color: root.active ? root.activeColor : Theme.surface

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: Theme.fontFamily
                font.pixelSize: 17
                color: root.active ? Theme.textOnPrimary : Theme.textMuted
            }
        }

        // Textos (Título + Subtítulo)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: Theme.text
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.subtitle
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: root.active ? root.activeColor : Theme.textSubtle
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Botão secundário opcional (abrir menu / atualizar)
        Rectangle {
            visible: root.hasSecondaryAction
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: 7
            color: secMouse.containsMouse ? Theme.hoverOverlay : "transparent"
            z: 2

            Text {
                anchors.centerIn: parent
                text: root.secondaryIcon
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.textMuted
            }

            MouseArea {
                id: secMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.secondaryClicked()
            }
        }
    }

    MouseArea {
        id: mainMouse
        anchors.fill: parent
        anchors.rightMargin: root.hasSecondaryAction ? 34 : 0
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton && root.hasSecondaryAction) {
                root.secondaryClicked()
            } else {
                root.clicked()
            }
        }
    }
}
