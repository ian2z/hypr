pragma Singleton
import QtQuick

QtObject {
    // Fundo Principal & Cards (Escuro estilo Ilha Dinâmica OLED)
    readonly property color background: "#0d0e15"
    readonly property color cardBackground: "#181926"
    readonly property color surface: "#222436"
    readonly property color surfaceActive: "#2d3047"

    // Tipografia
    readonly property color text: "#cdd6f4"
    readonly property color textMuted: "#bac2de"
    readonly property color textSubtle: "#9399b2"
    readonly property color textOnPrimary: "#0d0e15"

    // Bordas & Divisores
    readonly property color border: "#3d415d"
    readonly property color borderSubtle: "#2a2d42"

    // Cores de Ação do Powermenu
    readonly property color primary: "#89b4fa"   // Soft Lavender Blue
    readonly property color red:     "#f38ba8"   // Desligar
    readonly property color orange:  "#fab387"   // Reiniciar
    readonly property color calm:    "#89b4fa"   // Suspender
    readonly property color pacific: "#74c7ec"   // Encerrar Sessão (Logout)
    readonly property color ice:     "#cdd6f4"   // Bloquear

    // Curvaturas Modernas da Ilha
    readonly property int radiusLarge: 24
    readonly property int radiusMedium: 16
    readonly property int radiusSmall: 10
    readonly property int radiusPill: 999

    // Tipografia Nerd Font
    readonly property string fontFamily: "MesloLGS Nerd Font"
}
