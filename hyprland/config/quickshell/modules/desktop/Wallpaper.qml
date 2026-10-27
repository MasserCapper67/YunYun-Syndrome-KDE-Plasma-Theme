import QtQuick
import qs.theme

// Static or animated (gif/webp) wallpaper, cropped to fill the screen
Item {
    id: root

    property string path: ""
    readonly property bool animated: /\.(gif|webp)$/i.test(path)
    readonly property url source: path ? (path.startsWith("file:") ? path : "file://" + path) : ""

    Loader {
        anchors.fill: parent
        active: root.path !== ""
        sourceComponent: root.animated ? animatedImage : staticImage
    }

    Component {
        id: staticImage

        Image {
            source: root.source
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(root.width, root.height)
            asynchronous: true
            cache: false
        }
    }

    Component {
        id: animatedImage

        AnimatedImage {
            source: root.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            playing: true
        }
    }
}
