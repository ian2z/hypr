import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "style"
import "components"

Scope {
    id: root

    // Search for Spotify player or pick the first active MPRIS player
    readonly property var activePlayer: {
        var players = Mpris.players.values
        for (var i = 0; i < players.length; i++) {
            if (players[i].identity && players[i].identity.toLowerCase().indexOf("spotify") !== -1) {
                return players[i]
            }
        }
        return players.length > 0 ? players[0] : null
    }

    PanelWindow {
        id: mediaWindow
        visible: true

        anchors {
            top: true
            left: true
        }

        margins {
            top: 10
            left: 100
        }

        implicitWidth: 360
        implicitHeight: 145

        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: Theme.radiusLarge
            color: Theme.backgroundTransparent
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                AlbumArt {
                    artUrl: root.activePlayer ? (root.activePlayer.artUrl || root.activePlayer.trackArtUrl || "") : ""
                    size: 115
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Track Title
                    Text {
                        text: root.activePlayer && root.activePlayer.trackTitle ? root.activePlayer.trackTitle : "Spotify Desconectado"
                        font.pixelSize: 14
                        font.bold: true
                        color: Theme.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Artist Name
                    Text {
                        text: root.activePlayer && root.activePlayer.trackArtist ? root.activePlayer.trackArtist : (root.activePlayer && root.activePlayer.artist ? root.activePlayer.artist : "Abra o aplicativo de música")
                        font.pixelSize: 12
                        color: Theme.textMuted
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Timeline
                    Timeline {
                        player: root.activePlayer
                        Layout.fillWidth: true
                    }

                    // Controls
                    MediaControls {
                        player: root.activePlayer
                    }
                }
            }
        }
    }
}
