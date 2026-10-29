pragma Singleton
import QtQuick

QtObject {
    // Neutrals & Grays (Paleta idêntica ao Waybar)
    readonly property color black:   "#11111b" // Background
    readonly property color gray1:   "#bac2de" // Primary text
    readonly property color gray2:   "#9399b2" // Secondary text
    readonly property color gray3:   "#585b70" // Borders & Dividers
    readonly property color ice:     "#cdd6f4" // Highlights & Active

    // Calm Blues
    readonly property color calm:    "#89b4fa" // Soft Lavender Blue (Suspend)
    readonly property color pacific: "#74c7ec" // Calm Sky Blue (Exit / Logout)
    readonly property color ocean:   "#31748f" // Deep Muted Ocean Blue

    // Status Colors (Cores de urgência/ação)
    readonly property color red:     "#f38ba8" // Desligar
    readonly property color orange:  "#fab387" // Reiniciar
    readonly property color green:   "#a6e3a1" // Sucesso

    // Layout
    readonly property int radius: 0            // Minimalista 100% quadrado
    readonly property string fontFamily: "MesloLGS Nerd Font"
}
