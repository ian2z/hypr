pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    // Dispositivo de saída padrão atual
    readonly property var defaultSink: Pipewire.defaultAudioSink

    // Dispositivo de entrada padrão atual (Microfone)
    readonly property var defaultSource: Pipewire.defaultAudioSource

    // Lista de todos os dispositivos de saída de áudio (Sinks reais, ignorando streams)
    readonly property var audioSinks: {
        var list = []
        if (!Pipewire.nodes || !Pipewire.nodes.values) return list
        var allNodes = Pipewire.nodes.values
        for (var i = 0; i < allNodes.length; i++) {
            var n = allNodes[i]
            if (n && n.isSink && !n.isStream) {
                list.push(n)
            }
        }
        return list
    }

    // Rastreia sinks e microfone para manter volume e mute sincronizados em tempo real
    PwObjectTracker {
        objects: {
            var tracked = []
            if (root.defaultSink) tracked.push(root.defaultSink)
            if (root.defaultSource) tracked.push(root.defaultSource)
            for (var i = 0; i < root.audioSinks.length; i++) {
                if (tracked.indexOf(root.audioSinks[i]) === -1) {
                    tracked.push(root.audioSinks[i])
                }
            }
            return tracked
        }
    }

    // Volume (0.0 a 1.5) e porcentagem (0 a 150) do dispositivo de saída atual
    readonly property real volume: (defaultSink && defaultSink.audio && !isNaN(defaultSink.audio.volume))
        ? defaultSink.audio.volume
        : 0.0
    readonly property int volumePercent: Math.round(volume * 100)
    readonly property bool muted: (defaultSink && defaultSink.audio) ? defaultSink.audio.muted : false

    // Volume e mute do Microfone
    readonly property real micVolume: (defaultSource && defaultSource.audio && !isNaN(defaultSource.audio.volume))
        ? defaultSource.audio.volume
        : 0.0
    readonly property int micVolumePercent: Math.round(micVolume * 100)
    readonly property bool micMuted: (defaultSource && defaultSource.audio) ? defaultSource.audio.muted : false
    readonly property string micName: {
        if (!defaultSource) return "Sem Microfone"
        var desc = defaultSource.description || defaultSource.nickname || defaultSource.name || "Microfone"
        if (desc.indexOf("Fifine") !== -1) return "Fifine Microphone"
        if (desc.indexOf("Starship/Matisse") !== -1) return "Entrada Analógica (Placa-mãe)"
        return desc
    }

    function isSoundbarSink(node) {
        if (!node) return false
        var name = (node.name || "").toLowerCase()
        var desc = (node.description || "").toLowerCase()
        return name.indexOf("hdmi") !== -1 || desc.indexOf("hdmi") !== -1 ||
               desc.indexOf("displayport") !== -1 || desc.indexOf("24g2") !== -1 ||
               desc.indexOf("gm206") !== -1
    }

    function isHeadphoneSink(node) {
        if (!node) return false
        var name = (node.name || "").toLowerCase()
        var desc = (node.description || "").toLowerCase()
        var icon = (node.properties && node.properties["device.icon_name"]) ? String(node.properties["device.icon_name"]).toLowerCase() : ""
        return name.indexOf("headphone") !== -1 || name.indexOf("headset") !== -1 ||
               name.indexOf("analog") !== -1 || desc.indexOf("starship") !== -1 ||
               desc.indexOf("headphone") !== -1 || desc.indexOf("headset") !== -1 ||
               icon.indexOf("headphone") !== -1 || icon.indexOf("headset") !== -1
    }

    // Nome amigável de um dispositivo de saída no Desktop
    function sinkDisplayName(node) {
        if (!node) return "Sem saída de áudio"
        var desc = node.description || node.nickname || node.name || "Saída de Áudio"
        if (desc.indexOf("24G2") !== -1 || desc.indexOf("GM206") !== -1 || isSoundbarSink(node)) {
            return "Soundbar"
        }
        if (desc.indexOf("Starship/Matisse") !== -1 || desc.indexOf("Built-in Audio") !== -1 || isHeadphoneSink(node)) {
            return "Fone de Ouvido"
        }
        return desc
    }

    // Categoria descritiva do dispositivo
    function sinkCategoryLabel(node) {
        if (!node) return "Desconectado"
        if (isSoundbarSink(node)) return "Monitor (DisplayPort)"
        if (isHeadphoneSink(node)) return "Saída P2 (Placa-mãe)"
        return "Saída de Áudio"
    }

    // Ícone dinâmico conforme dispositivo e nível de volume
    function sinkIcon(node, isMuted, volPercent) {
        if (!node) return "󰝟"
        if (isMuted) return "󰝟"
        if (isHeadphoneSink(node)) return ""
        if (volPercent <= 0) return ""
        if (volPercent < 50) return ""
        return ""
    }

    readonly property string activeDeviceName: sinkDisplayName(defaultSink)
    readonly property string activeDeviceCategory: sinkCategoryLabel(defaultSink)
    readonly property string activeDeviceIcon: sinkIcon(defaultSink, muted, volumePercent)

    // Funções de controle
    function setVolume(newVol) {
        if (defaultSink && defaultSink.audio) {
            var clamped = Math.max(0.0, Math.min(1.5, newVol))
            defaultSink.audio.volume = clamped
        }
    }

    function toggleMute() {
        if (defaultSink && defaultSink.audio) {
            defaultSink.audio.muted = !defaultSink.audio.muted
        }
    }

    function toggleMicMute() {
        if (defaultSource && defaultSource.audio) {
            defaultSource.audio.muted = !defaultSource.audio.muted
        }
    }

    function selectSink(node) {
        if (node) {
            Pipewire.preferredDefaultAudioSink = node
        }
    }
}
