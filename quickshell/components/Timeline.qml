import QtQuick
import QtQuick.Layouts
import "../style"

ColumnLayout {
    id: root
    property var player: null
    spacing: 6

    function formatTime(seconds) {
        if (!seconds || seconds <= 0 || isNaN(seconds)) return "00:00"
        var secs = Math.floor(seconds)
        var mins = Math.floor(secs / 60)
        var remSecs = secs % 60
        return (mins < 10 ? "0" + mins : mins) + ":" + (remSecs < 10 ? "0" + remSecs : remSecs)
    }

    // Interactive Seek Slider / Progress Bar
    Rectangle {
        id: sliderTrack
        Layout.fillWidth: true
        height: 6
        radius: 3
        color: Theme.surface

        Rectangle {
            id: sliderProgress
            height: parent.height
            radius: parent.radius
            color: Theme.primary
            width: {
                if (!root.player || !root.player.length || root.player.length <= 0) return 0
                var progress = root.player.position / root.player.length
                return Math.min(Math.max(progress * sliderTrack.width, 0), sliderTrack.width)
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (root.player && root.player.length > 0 && root.player.canSeek) {
                    var percentage = mouse.x / sliderTrack.width
                    root.player.position = percentage * root.player.length
                }
            }
        }
    }

    // Time Labels
    RowLayout {
        Layout.fillWidth: true

        Text {
            text: root.player ? root.formatTime(root.player.position) : "00:00"
            font.pixelSize: 11
            color: Theme.textMuted
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: root.player ? root.formatTime(root.player.length) : "00:00"
            font.pixelSize: 11
            color: Theme.textMuted
        }
    }
}
