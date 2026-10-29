pragma Singleton
import QtQuick

QtObject {
    // Paleta Principal (Desktop Minimalist Monochrome & Calm Blues)
    readonly property color background: "#11111b"              // @black (Fundo principal)
    readonly property color backgroundTransparent: "#f211111b" // @black com leve transparência
    readonly property color cardBackground: "#181825"          // Card elevado sutil sobre @black
    readonly property color surface: "#24253a"                 // Hover / elementos internos
    readonly property color surfaceActive: "#313244"           // Surface mais clara para clique/ativo

    // Destaques & Acentos
    readonly property color primary: "#89b4fa"                 // @calm (Soft Lavender Blue - Destaques principais)
    readonly property color accent: "#74c7ec"                  // @pacific (Calm Sky Blue)

    // Cores de Status (Urgência / Eventos)
    readonly property color green: "#a6e3a1"                   // Sucesso / Conectado / OK
    readonly property color orange: "#fab387"                  // Alerta / Atenção (Hyprsunset / Avisos)
    readonly property color red: "#f38ba8"                     // Crítico / Desconectado / Erro

    // Tipografia & Texto
    readonly property color text: "#cdd6f4"                    // @ice (Texto principal em destaque)
    readonly property color textMuted: "#bac2de"               // @gray1 (Texto primário padrão)
    readonly property color textSubtle: "#9399b2"              // @gray2 (Texto secundário / sutil)
    readonly property color textOnPrimary: "#11111b"           // @black (Texto sobre fundo primary/accent)

    // Bordas & Overlays
    readonly property color border: "#585b70"                  // @gray3 (Bordas / Divisores)
    readonly property color borderSubtle: "#66585b70"          // @gray3 translúcido para divisórias internas
    readonly property color hoverOverlay: "#20cdd6f4"

    // Estilo Minimalista 100% Quadrado (igual Waybar, Rofi e Powermenu)
    readonly property int radiusLarge: 0
    readonly property int radiusMedium: 0
    readonly property int radiusSmall: 0

    // Fonte Padrão do Sistema
    readonly property string fontFamily: "MesloLGS Nerd Font"
}
