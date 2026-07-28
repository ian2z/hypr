pragma Singleton
import QtQuick

QtObject {
    // Colors derived directly from cream.css palette
    readonly property color background: "#2C1A14"            // coffy
    readonly property color backgroundTransparent: "#f22C1A14"  // coffy with smooth opacity
    readonly property color cardBackground: "#2C1A14"        // coffy
    readonly property color surface: "#4A352C"               // surface1 (lighter brown for hover/elements)
    
    readonly property color primary: "#D4A373"               // caramel (Highlights)
    readonly property color accent: "#EFE6DC"                // sand
    readonly property color green: "#a6e3a1"                 // green
    
    readonly property color text: "#FFFDF9"                  // cream (Primary text)
    readonly property color textMuted: "#EFE6DC"             // sand (Secondary text)
    readonly property color textSubtle: "#8C7A6B"            // sepia (Borders / Muted text)
    
    // Borders & Overlays
    readonly property color border: "#8C7A6B"                // sepia
    readonly property color hoverOverlay: "#20FFFDF9"
    
    // Sizes & Radius
    readonly property int radiusLarge: 18
    readonly property int radiusMedium: 12
    readonly property int radiusSmall: 8
    
    // Fonts
    readonly property string fontFamily: "Sans-Serif"
}
