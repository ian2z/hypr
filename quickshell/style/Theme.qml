pragma Singleton
import QtQuick

QtObject {
    // Paleta Principal (derivada do cream.css)
    readonly property color background: "#2C1A14"              // @coffy
    readonly property color backgroundTransparent: "#f02C1A14" // @coffy com opacidade suave
    readonly property color cardBackground: "#38231C"          // Card elevado sutil sobre @coffy
    readonly property color surface: "#4A352C"                 // @surface1 (hover / elementos internos)
    readonly property color surfaceActive: "#5C4338"           // surface mais clara para clique/ativo

    // Destaques & Acentos
    readonly property color primary: "#D4A373"                 // @caramel (Destaques principais)
    readonly property color accent: "#EFE6DC"                  // @sand

    // Cores de Status (cream.css)
    readonly property color green: "#a6e3a1"                   // Sucesso / Conectado / Bateria OK
    readonly property color orange: "#fab387"                  // Alerta / Atenção
    readonly property color red: "#f38ba8"                     // Crítico / Desconectado / Erro

    // Tipografia & Texto
    readonly property color text: "#FFFDF9"                    // @cream (Texto principal)
    readonly property color textMuted: "#EFE6DC"               // @sand (Texto secundário)
    readonly property color textSubtle: "#8C7A6B"              // @sepia (Texto sutil / desabilitado)
    readonly property color textOnPrimary: "#2C1A14"           // @coffy (Texto sobre fundo caramel)

    // Bordas & Overlays
    readonly property color border: "#8C7A6B"                  // @sepia
    readonly property color borderSubtle: "#558C7A6B"          // @sepia translúcido para divisórias internas
    readonly property color hoverOverlay: "#20FFFDF9"

    // Tamanhos & Bordas Arredondadas
    readonly property int radiusLarge: 18
    readonly property int radiusMedium: 12
    readonly property int radiusSmall: 8

    // Fontes
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
}
