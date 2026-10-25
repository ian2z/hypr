import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../style"
import "../components"

Rectangle {
    id: root

    property int selectedPlayerIndex: -1

    readonly property var playersList: (Mpris.players && Mpris.players.values) ? Mpris.players.values : []

    // Prioriza Spotify por padrão, mas permite alternar entre outros players MPRIS ativos
    readonly property var activePlayer: {
        if (playersList.length === 0) return null
        if (selectedPlayerIndex >= 0 && selectedPlayerIndex < playersList.length) {
            return playersList[selectedPlayerIndex]
        }
        for (var i = 0; i < playersList.length; i++) {
            var id = (playersList[i].identity || "").toLowerCase()
            if (id.indexOf("spotify") !== -1) {
                return playersList[i]
            }
        }
        return playersList[0]
    }

    readonly property string playerName: {
        if (!activePlayer || !activePlayer.identity) return "Spotify"
        return activePlayer.identity
    }

    readonly property string playerIcon: {
        var id = playerName.toLowerCase()
        if (id.indexOf("spotify") !== -1) return ""
        if (id.indexOf("firefox") !== -1 || id.indexOf("zen") !== -1) return "󰈹"
        return "󰝚"
    }

    function nextPlayer() {
        if (playersList.length <= 1) return
        if (selectedPlayerIndex < 0) {
            selectedPlayerIndex = 0
        } else {
            selectedPlayerIndex = (selectedPlayerIndex + 1) % playersList.length
        }
    }

    Layout.fillWidth: true
    implicitHeight: cardCol.implicitHeight + 24
    radius: Theme.radiusMedium
    color: Theme.cardBackground
    border.color: Theme.borderSubtle
    border.width: 1

    ColumnLayout {
        id: cardCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10

        // Topo do Card: Badge do Player + Visualizador de Áudio + Alternador de Player
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Badge do Player (Spotify / Navegador)
            Rectangle {
                Layout.preferredHeight: 24
                Layout.preferredWidth: badgeRow.implicitWidth + 14
                radius: 7
                color: Theme.surface

                RowLayout {
                    id: badgeRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: root.playerIcon
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.primary
                    }

                    Text {
                        text: root.playerName
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.textMuted
                    }
                }
            }

            // Visualizador de Espectro de Mídia em Tempo Real
            AudioVisualizer {
                active: root.activePlayer ? root.activePlayer.isPlaying : false
                barCount: 16
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }

            // Botão para alternar entre players ativos (ex: Spotify <-> Zen Browser)
            Rectangle {
                visible: root.playersList.length > 1
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 7
                color: switchPlayerMouse.containsMouse ? Theme.surfaceActive : Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "󰓦"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.primary
                }

                MouseArea {
                    id: switchPlayerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextPlayer()
                }
            }
        }

        // Corpo do Player: Capa do Álbum + Info da Faixa + Timeline + Controles
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            AlbumArt {
                artUrl: root.activePlayer ? (root.activePlayer.artUrl || root.activePlayer.trackArtUrl || "") : ""
                size: 104
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                // Título da Música
                Text {
                    text: root.activePlayer && root.activePlayer.trackTitle
                        ? root.activePlayer.trackTitle
                        : "Nenhuma mídia ativa"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.text
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Nome do Artista
                Text {
                    text: root.activePlayer && root.activePlayer.trackArtist
                        ? root.activePlayer.trackArtist
                        : (root.activePlayer && root.activePlayer.artist
                            ? root.activePlayer.artist
                            : "Abra o Spotify ou player de mídia")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.textMuted
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Barra de Tempo Interativa
                Timeline {
                    player: root.activePlayer
                    Layout.fillWidth: true
                }

                // Botões de Controle (Prev / Play-Pause / Next)
                MediaControls {
                    player: root.activePlayer
                }
            }
        }
    }
}
