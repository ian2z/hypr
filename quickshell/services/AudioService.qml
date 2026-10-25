pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    // Dispositivo de saída padrão atual (Fone conectado ou Alto-falantes)
    readonly property var defaultSink: Pipewire.defaultAudioSink

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

    // Rastreia todos os sinks para manter volume, mute e propriedades sincronizados em tempo real
    PwObjectTracker {
        objects: {
            var tracked = []
            if (root.defaultSink) tracked.push(root.defaultSink)
            for (var i = 0; i < root.audioSinks.length; i++) {
                if (tracked.indexOf(root.audioSinks[i]) === -1) {
                    tracked.push(root.audioSinks[i])
                }
            }
            return tracked
        }
    }

    // Volume (0.0 a 1.5) e porcentagem (0 a 150) do dispositivo atual
    readonly property real volume: (defaultSink && defaultSink.audio && !isNaN(defaultSink.audio.volume))
        ? defaultSink.audio.volume
        : 0.0
    readonly property int volumePercent: Math.round(volume * 100)
    readonly property bool muted: (defaultSink && defaultSink.audio) ? defaultSink.audio.muted : false

    // Detecta se um sink específico é fone Bluetooth, fone cabeado, HDMI ou Alto-falante
    function isBluetoothSink(node) {
        if (!node) return false
        var name = (node.name || "").toLowerCase()
        var desc = (node.description || "").toLowerCase()
        var icon = (node.properties && node.properties["device.icon_name"]) ? String(node.properties["device.icon_name"]).toLowerCase() : ""
        return name.indexOf("bluez") !== -1 || icon.indexOf("bluetooth") !== -1 || desc.indexOf("tws") !== -1
    }

    function isHeadphoneSink(node) {
        if (!node) return false
        if (isBluetoothSink(node)) return true
        var name = (node.name || "").toLowerCase()
        var desc = (node.description || "").toLowerCase()
        var icon = (node.properties && node.properties["device.icon_name"]) ? String(node.properties["device.icon_name"]).toLowerCase() : ""
        return name.indexOf("headphone") !== -1 || name.indexOf("headset") !== -1 ||
               desc.indexOf("headphone") !== -1 || desc.indexOf("headset") !== -1 || desc.indexOf("fone") !== -1 ||
               icon.indexOf("headphone") !== -1 || icon.indexOf("headset") !== -1
    }

    // Nome amigável de um dispositivo de saída
    function sinkDisplayName(node) {
        if (!node) return "Sem saída de áudio"
        var desc = node.description || node.nickname || node.name || "Saída de Áudio"
        if (desc.indexOf("Áudio interno") !== -1 || desc.indexOf("Built-in Audio") !== -1) {
            return isHeadphoneSink(node) ? "Fone Cabeado (Interno)" : "Alto-falantes (Laptop)"
        }
        return desc
    }

    // Tipo descritivo do dispositivo (ex: "Fone Bluetooth", "Alto-falantes")
    function sinkCategoryLabel(node) {
        if (!node) return "Desconectado"
        if (isBluetoothSink(node)) return "Fone Bluetooth"
        if (isHeadphoneSink(node)) return "Fone de Ouvido"
        return "Alto-falantes"
    }

    // Ícone dinâmico conforme dispositivo e nível de volume
    function sinkIcon(node, isMuted, volPercent) {
        if (!node) return "󰝟"
        if (isMuted) return "󰝟"
        if (isBluetoothSink(node)) return "󰂰"
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

    function setNodeVolume(node, newVol) {
        if (node && node.audio) {
            var clamped = Math.max(0.0, Math.min(1.5, newVol))
            node.audio.volume = clamped
        }
    }

    function toggleMute() {
        if (defaultSink && defaultSink.audio) {
            defaultSink.audio.muted = !defaultSink.audio.muted
        }
    }

    function selectSink(node) {
        if (node) {
            Pipewire.preferredDefaultAudioSink = node
        }
    }
}
