import QtQuick
import qs.theme

// A 9-slice frame rendered from the Plasma theme SVGs (see tools/render-theme-assets.py).
// The @2x variant is picked automatically on scaled outputs.
Item {
    id: root

    property string kind: "dialog"
    readonly property var metrics: Frames.get(kind)

    // Content padding the SVG asks for (its hint-*-margin elements)
    readonly property int padLeft: metrics.ml
    readonly property int padTop: metrics.mt
    readonly property int padRight: metrics.mr
    readonly property int padBottom: metrics.mb

    BorderImage {
        anchors.fill: parent
        source: root.kind ? Theme.asset("frames/" + root.kind + ".png") : ""
        border.left: root.metrics.l
        border.top: root.metrics.t
        border.right: root.metrics.r
        border.bottom: root.metrics.b
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
        smooth: false
    }
}
