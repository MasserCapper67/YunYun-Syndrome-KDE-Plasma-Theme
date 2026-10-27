pragma Singleton

import QtQuick
import Quickshell

// Colors and metrics taken from the KDE theme: YunYunSyndrome.colors, the Plasma
// SVGs and measurements of the original screenshots.
Singleton {
    // Color scheme
    readonly property color night: "#04001d"      // Window/View BackgroundNormal
    readonly property color text: "#7f62d3"       // Window ForegroundNormal
    readonly property color textBright: "#e0dcf8" // View ForegroundNormal
    readonly property color textDim: "#4b3f86"
    readonly property color textOff: "#3a3654"    // days outside the current month
    readonly property color selection: "#0e1833"  // Selection BackgroundNormal
    readonly property color hover: "#8668a8"      // DecorationHover

    // Plasma style
    readonly property color panel: "#1a1939"
    readonly property color magenta: "#973a98"
    readonly property color pink: "#bf59d2"
    readonly property color lavender: "#8a8cf0"
    readonly property color blue: "#7d9ff6"
    readonly property color visualizer: "#7c5ce0"

    // Desktop decorations
    readonly property color checkerStart: "#b779fe"
    readonly property color checkerEnd: "#fac1ad"
    readonly property color barPurple: "#785ad6"
    readonly property color barPink: "#d85ac8"
    readonly property color iconTop: "#f9bab1"
    readonly property color iconBottom: "#cd92e4"
    readonly property color iconGlyph: "#1a1236"

    readonly property string font: "Fira Sans"
    readonly property string monoFont: "JetBrainsMono Nerd Font"
    readonly property int fontWeight: Font.DemiBold
    readonly property int fontSize: 14

    readonly property int barHeight: 43
    readonly property int barLine: 2

    // Locale names start lowercase in some languages ("octubre", "lun")
    function capitalize(text) {
        const s = String(text);
        return s.charAt(0).toLocaleUpperCase() + s.slice(1);
    }

    function asset(path) {
        return Qt.resolvedUrl("../assets/" + path);
    }
}
