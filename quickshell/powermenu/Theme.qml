pragma Singleton
import QtQuick

QtObject {
    // Fundo Principal & Cards (Cream / Coffy - Laptop)
    readonly property color background: "#2C1A14"              // @coffy
    readonly property color cardBackground: "#38231C"          // Card elevado
    readonly property color surface: "#4A352C"                 // @surface1
    readonly property color surfaceActive: "#5C4338"           // Hover / Ativo

    // Tipografia
    readonly property color text: "#FFFDF9"                    // @cream
    readonly property color textMuted: "#EFE6DC"               // @sand
    readonly property color textSubtle: "#8C7A6B"              // @sepia
    readonly property color textOnPrimary: "#2C1A14"           // @coffy

    // Bordas & Divisores
    readonly property color border: "#8C7A6B"                  // @sepia
    readonly property color borderSubtle: "#558C7A6B"

    // Cores de Ação do Powermenu
    readonly property color primary: "#D4A373"                 // @caramel
    readonly property color red:     "#f38ba8"                 // Desligar
    readonly property color orange:  "#fab387"                 // Reiniciar
    readonly property color calm:    "#D4A373"                 // Suspender
    readonly property color pacific: "#EFE6DC"                 // Encerrar Sessão (Logout)
    readonly property color ice:     "#FFFDF9"                 // Bloquear

    // Curvaturas Modernas da Ilha
    readonly property int radiusLarge: 20
    readonly property int radiusMedium: 14
    readonly property int radiusSmall: 8
    readonly property int radiusPill: 999

    // Tipografia Nerd Font
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
}
