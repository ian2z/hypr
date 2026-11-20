import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import "../style"
import "../services"
import "../components"

Rectangle {
    id: islandRoot

    // -------------------------------------------------------------------------
    // Estados & Propriedades
    // -------------------------------------------------------------------------
    property bool isExpanded: false
    property bool showingHud: false
    property string hudType: "volume" // "volume" | "mic"

    // Notificações
    property bool showingNotification: false

    // Mídia (Spotify / MPRIS)
    property bool showingTrackBanner: false
    property string lastTrackKey: ""

    readonly property var playersList: (Mpris.players && Mpris.players.values) ? Mpris.players.values : []
    readonly property var activePlayer: {
        if (!playersList || playersList.length === 0) return null
        // Detecção exclusiva para o Spotify (ignora navegadores, youtube, whatsapp, etc.)
        for (var i = 0; i < playersList.length; i++) {
            var p = playersList[i]
            if (p) {
                var id = (p.identity || "").toLowerCase()
                var entry = (p.desktopEntry || "").toLowerCase()
                if (id.indexOf("spotify") !== -1 || entry.indexOf("spotify") !== -1) {
                    return p
                }
            }
        }
        return null
    }

    readonly property bool isPlaying: {
        if (!activePlayer) return false
        if (activePlayer.isPlaying === true) return true
        var state = String(activePlayer.playbackState || "").toLowerCase()
        return state.indexOf("playing") !== -1
    }

    readonly property string currentArtist: {
        if (!activePlayer) return ""
        return activePlayer.trackArtist || activePlayer.artist || ""
    }

    readonly property string currentTitle: {
        if (!activePlayer) return ""
        return activePlayer.trackTitle || activePlayer.title || ""
    }

    readonly property bool hasMusic: currentTitle !== "" || currentArtist !== ""

    readonly property string playerIcon: ""

    readonly property string mediaDisplayText: {
        if (!activePlayer) return ""
        if (currentArtist !== "" && currentTitle !== "") {
            return currentArtist + " - " + currentTitle
        }
        if (currentTitle !== "") return currentTitle
        if (currentArtist !== "") return currentArtist
        return "Playing"
    }

    TextMetrics {
        id: mediaMetrics
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: islandRoot.showingTrackBanner
        text: islandRoot.mediaDisplayText
    }

    readonly property int playingAdaptiveWidth: {
        var base = Math.round(148 + mediaMetrics.width)
        if (showingTrackBanner) base += 14
        return Math.min(420, Math.max(220, base))
    }

    // -------------------------------------------------------------------------
    // Geometria Dinâmica (Pílula Flutuante Centralizada - Morphing Suave)
    // -------------------------------------------------------------------------
    width: {
        if (isExpanded) return 440
        if (showingNotification) return 380
        if (showingHud) return 290
        if (isPlaying) return playingAdaptiveWidth
        return 190
    }

    height: {
        if (isExpanded) return expandedCol.implicitHeight + 28
        if (showingNotification) return 66
        if (showingHud) return 40
        if (showingTrackBanner && isPlaying) return 40
        return 36
    }

    radius: {
        if (isExpanded) return 24
        if (showingNotification) return 20
        return height / 2
    }

    // Cores e Borda
    color: Theme.backgroundTransparent
    border.color: {
        if (isExpanded) return Theme.primary
        if (showingNotification) {
            return NotificationService.urgency === 2 ? Theme.red : Theme.primary
        }
        if (islandMouse.containsMouse) return Theme.accent
        return Theme.border
    }
    border.width: 1
    clip: true

    // Animações de Física
    Behavior on width {
        NumberAnimation { duration: 380; easing.type: Easing.OutQuint }
    }
    Behavior on height {
        NumberAnimation { duration: 380; easing.type: Easing.OutQuint }
    }
    Behavior on radius {
        NumberAnimation { duration: 380; easing.type: Easing.OutQuint }
    }
    Behavior on border.color {
        ColorAnimation { duration: 250 }
    }

    // -------------------------------------------------------------------------
    // Lógica de Notificações Integradas
    // -------------------------------------------------------------------------
    Timer {
        id: notifTimer
        interval: 5000
        repeat: false
        onTriggered: {
            islandRoot.showingNotification = false
            NotificationService.dismissCurrent()
        }
    }

    Connections {
        target: NotificationService
        function onNotificationReceived(notif) {
            if (islandRoot.isExpanded) return
            islandRoot.showingNotification = true
            var timeout = (notif && notif.expireTimeout > 0) ? (notif.expireTimeout * 1000) : 5000
            notifTimer.interval = Math.max(3000, Math.min(8000, timeout))
            notifTimer.restart()
        }
    }

    function dismissNotification() {
        islandRoot.showingNotification = false
        notifTimer.stop()
        NotificationService.dismissCurrent()
    }

    // -------------------------------------------------------------------------
    // Lógica de Anúncio de Mídia (Aparece ao trocar/iniciar e depois recolhe)
    // -------------------------------------------------------------------------
    Timer {
        id: trackBannerTimer
        interval: 3800
        repeat: false
        onTriggered: {
            islandRoot.showingTrackBanner = false
        }
    }

    function triggerTrackBanner() {
        if (isExpanded || showingNotification) return
        showingTrackBanner = true
        trackBannerTimer.restart()
    }

    onCurrentTitleChanged: {
        var key = currentArtist + "::" + currentTitle
        if (key !== "" && key !== lastTrackKey) {
            lastTrackKey = key
            if (isPlaying) {
                triggerTrackBanner()
            }
        }
    }

    onIsPlayingChanged: {
        if (isPlaying) {
            triggerTrackBanner()
        }
    }

    // -------------------------------------------------------------------------
    // Lógica de HUD de Volume / Mic
    // -------------------------------------------------------------------------
    Timer {
        id: hudTimer
        interval: 1800
        repeat: false
        onTriggered: {
            islandRoot.showingHud = false
        }
    }

    function triggerHud(type) {
        if (isExpanded || showingNotification) return
        hudType = type
        showingHud = true
        hudTimer.restart()
    }

    Connections {
        target: AudioService
        function onVolumeChanged() {
            islandRoot.triggerHud("volume")
        }
        function onMutedChanged() {
            islandRoot.triggerHud("volume")
        }
        function onMicMutedChanged() {
            islandRoot.triggerHud("mic")
        }
    }

    // -------------------------------------------------------------------------
    // Relógio Digital & Data da Ilha
    // -------------------------------------------------------------------------
    property string currentTime: "00:00"
    property string currentDateShort: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            var h = String(d.getHours()).padStart(2, '0')
            var m = String(d.getMinutes()).padStart(2, '0')
            islandRoot.currentTime = h + ":" + m

            var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            islandRoot.currentDateShort = days[d.getDay()] + ", " + d.getDate() + " " + months[d.getMonth()]
        }
    }

    // -------------------------------------------------------------------------
    // Interação do Mouse na Ilha
    // -------------------------------------------------------------------------
    MouseArea {
        id: islandMouse
        anchors.fill: parent
        enabled: !islandRoot.isExpanded
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (islandRoot.showingNotification) {
                islandRoot.dismissNotification()
                return
            }

            if (mouse.button === Qt.RightButton) {
                if (islandRoot.activePlayer) islandRoot.activePlayer.togglePlaying()
            } else {
                islandRoot.isExpanded = !islandRoot.isExpanded
                if (islandRoot.isExpanded) {
                    islandRoot.showingHud = false
                    islandRoot.showingNotification = false
                }
            }
        }

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                AudioService.setVolume(Math.min(1.0, AudioService.volume + 0.03))
            } else if (wheel.angleDelta.y < 0) {
                AudioService.setVolume(Math.max(0.0, AudioService.volume - 0.03))
            }
            islandRoot.triggerHud("volume")
        }
    }

    // =========================================================================
    // CAMADA 1: MODO NOTIFICAÇÃO (Estilo Dunst Integrado)
    // =========================================================================
    RowLayout {
        id: notifView
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12
        visible: islandRoot.showingNotification && !islandRoot.isExpanded
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }

        // Ícone da Notificação ou Sino
        Rectangle {
            width: 36
            height: 36
            radius: 10
            color: Theme.surface
            border.color: Theme.borderSubtle
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: NotificationService.urgency === 2 ? "󰅚" : "󰂚"
                font.family: Theme.fontFamily
                font.pixelSize: 18
                color: NotificationService.urgency === 2 ? Theme.red : Theme.primary
            }
        }

        // Conteúdo da Notificação (App + Título + Mensagem)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: NotificationService.appName
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    color: Theme.primary
                }

                Text {
                    text: "• now"
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    color: Theme.textSubtle
                }

                Item { Layout.fillWidth: true }
            }

            Text {
                Layout.fillWidth: true
                text: NotificationService.summary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: Theme.text
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: NotificationService.body
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.textSubtle
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        // Botão Fechar Notificação
        Text {
            text: "󰅖"
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.textSubtle
        }
    }

    // =========================================================================
    // CAMADA 2: MODO HUD DE VOLUME / MICROFONE
    // =========================================================================
    RowLayout {
        id: hudView
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10
        visible: islandRoot.showingHud && !islandRoot.showingNotification && !islandRoot.isExpanded
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }

        Text {
            text: {
                if (islandRoot.hudType === "mic") {
                    return AudioService.micMuted ? "" : ""
                }
                if (AudioService.muted) return "󰝟"
                if (AudioService.volumePercent > 60) return "󰕾"
                if (AudioService.volumePercent > 20) return "󰖀"
                return "󰕿"
            }
            font.family: Theme.fontFamily
            font.pixelSize: 15
            color: (AudioService.muted || (islandRoot.hudType === "mic" && AudioService.micMuted)) ? Theme.red : Theme.primary
        }

        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: "#282a3c"

            Rectangle {
                height: parent.height
                radius: parent.radius
                color: AudioService.muted ? Theme.red : Theme.primary
                width: Math.min(parent.width, Math.max(0, parent.width * (AudioService.volumePercent / 100.0)))
                Behavior on width {
                    NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                }
            }
        }

        Text {
            text: {
                if (islandRoot.hudType === "mic") {
                    return AudioService.micMuted ? "Muted" : AudioService.micVolumePercent + "%"
                }
                return AudioService.muted ? "Muted" : AudioService.volumePercent + "%"
            }
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
            color: Theme.text
        }
    }

    // =========================================================================
    // CAMADA 3: MÍDIA TOCANDO (Logo, Artista - Música, Visualizador + Info)
    // =========================================================================
    RowLayout {
        id: compactPlayingView
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8
        visible: islandRoot.isPlaying && !islandRoot.showingHud && !islandRoot.showingNotification && !islandRoot.isExpanded
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }

        // Informações do Sistema (sempre visíveis mesmo com música tocando)
        RowLayout {
            spacing: 6

            // Badge com número da área de trabalho ativa (Workspace)
            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: wsMouse1.containsMouse ? Theme.surfaceActive : Theme.surface
                border.color: Theme.borderSubtle
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.name || Hyprland.focusedWorkspace.id) : "1"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.primary
                }

                MouseArea {
                    id: wsMouse1
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onWheel: (wheel) => {
                        if (wheel.angleDelta.y > 0) {
                            Quickshell.execDetached(["hyprctl", "dispatch", "workspace", "m+1"])
                        } else if (wheel.angleDelta.y < 0) {
                            Quickshell.execDetached(["hyprctl", "dispatch", "workspace", "m-1"])
                        }
                    }
                }
            }

            Text {
                text: islandRoot.currentTime
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                color: Theme.text
            }
        }

        // Divisor sutil
        Rectangle {
            width: 1
            height: 12
            color: Theme.borderSubtle
        }

        // Texto da Música (Artista - Música)
        Item {
            Layout.fillWidth: true
            Layout.minimumWidth: 50
            Layout.preferredWidth: mediaMetrics.width
            height: parent.height
            clip: true

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                text: islandRoot.mediaDisplayText
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: islandRoot.showingTrackBanner
                color: islandRoot.showingTrackBanner ? Theme.text : Theme.textMuted
                elide: Text.ElideRight
            }
        }

        // Barras de áudio animadas em tempo real + Ícone de saída de som
        RowLayout {
            spacing: 6
            Item {
                width: 24
                height: 16

                AudioVisualizer {
                    anchors.fill: parent
                    active: true
                    barCount: 4
                }
            }

            Text {
                text: AudioService.isHeadphone ? "󰋋" : "󰓃"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.textSubtle
            }
        }
    }

    // =========================================================================
    // CAMADA 4: MODO OCIOSO / PAUSADO (Ilha Normal Padrão)
    // =========================================================================
    RowLayout {
        id: idleView
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 8
        visible: !islandRoot.isPlaying && !islandRoot.showingHud && !islandRoot.showingNotification && !islandRoot.isExpanded
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        // Badge com número da área de trabalho ativa (Workspace)
        Rectangle {
            width: 20
            height: 20
            radius: 10
            color: wsMouse2.containsMouse ? Theme.surfaceActive : Theme.surface
            border.color: Theme.borderSubtle
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.name || Hyprland.focusedWorkspace.id) : "1"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                color: Theme.primary
            }

            MouseArea {
                id: wsMouse2
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) {
                        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", "m+1"])
                    } else if (wheel.angleDelta.y < 0) {
                        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", "m-1"])
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: islandRoot.currentTime
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
            color: Theme.text
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: AudioService.isHeadphone ? "󰋋" : "󰓃"
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: Theme.textSubtle
        }
    }

    // =========================================================================
    // CAMADA 5: MODO EXPANDIDO (Painel de Controle Completo Integrado)
    // =========================================================================
    ColumnLayout {
        id: expandedCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 10
        visible: islandRoot.isExpanded
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 240; easing.type: Easing.OutQuad }
        }

        // 1. Cabeçalho Geral (Usuário, Hardware CPU/RAM, Uptime, Bloqueio, Powermenu, Fechar)
        HeaderBar {
            onCollapseRequested: islandRoot.isExpanded = false
        }

        // 2. Acessos Rápidos (Rede Cabeada, Hyprsunset, Updates, Não Perturbe)
        QuickSettingsGrid {}

        // 3. Calendário Completo e Data de Acesso Rápido
        CalendarCard {}

        // 4. Controle de Volume Inteligente (Monitor / Fone + Microfone + Seletor de Saída)
        AudioPanel {}

        // 5. Player do Spotify / Mídia Completo com Capa, Timeline e Controles
        MediaCard {}
    }
}
