import QtQuick
import qs.theme

// Two-row checkered strip fading from purple (screen edge) to peach (inner end)
Item {
    id: root

    property bool mirrored: false
    readonly property int square: 7
    readonly property int count: 10

    width: square * 2 * count
    height: square * 2

    Repeater {
        model: root.count * 2

        Rectangle {
            required property int index
            readonly property int row: index % 2
            readonly property int col: Math.floor(index / 2)
            // Top row is offset by one square
            readonly property real px: col * root.square * 2 + (row === 0 ? root.square : 0)
            readonly property real t: px / (root.width - root.square)

            x: root.mirrored ? root.width - root.square - px : px
            y: row * root.square
            width: root.square
            height: root.square
            color: Qt.rgba(Theme.checkerStart.r + (Theme.checkerEnd.r - Theme.checkerStart.r) * t,
                           Theme.checkerStart.g + (Theme.checkerEnd.g - Theme.checkerStart.g) * t,
                           Theme.checkerStart.b + (Theme.checkerEnd.b - Theme.checkerStart.b) * t, 1)
        }
    }
}
