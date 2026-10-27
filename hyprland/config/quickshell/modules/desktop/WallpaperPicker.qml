import QtQuick
import QtQuick.Controls.Basic as Controls
import Qt.labs.folderlistmodel
import Quickshell
import qs.components
import qs.services
import qs.theme

// Wallpaper chooser: thumbnails from your wallpaper folders, or type a path
PopupSurface {
    id: root

    popupName: "wallpapers"

    readonly property var folders: {
        const home = Quickshell.env("HOME");
        const list = [...Settings.wallpaperDirs];
        const current = Settings.wallpaper.substring(0, Settings.wallpaper.lastIndexOf("/"));
        for (const dir of [current, home + "/Pictures/Wallpapers", home + "/Pictures"]) {
            if (dir && !list.includes(dir))
                list.push(dir);
        }
        return list;
    }
    property int folderIndex: 0

    function apply(path) {
        const clean = path.trim().replace(/^file:\/\//, "").replace(/^~/, Quickshell.env("HOME"));
        if (clean)
            Settings.wallpaper = clean;
    }

    onVisibleChanged: if (visible) pathInput.text = Settings.wallpaper

    Frame {
        id: panel

        anchors.centerIn: parent
        width: Math.min(860, parent.width - 160)
        height: Math.min(600, parent.height - 120)
        kind: "dialog"

        MouseArea {
            anchors.fill: parent
        }

        StyledText {
            id: title

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 16
            anchors.topMargin: 12
            text: "Wallpaper"
            color: Theme.textBright
            font.pixelSize: 17
        }

        Row {
            id: tabs

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: title.bottom
            anchors.topMargin: 8
            anchors.leftMargin: 8
            height: 36
            clip: true

            Repeater {
                model: root.folders

                FrameButton {
                    id: tab

                    required property string modelData
                    required property int index

                    width: Math.max(110, tabLabel.implicitWidth + 28)
                    height: 36
                    checked: root.folderIndex === index
                    hoverFrame: ""
                    pressedFrame: "tab-active"
                    onClicked: root.folderIndex = index

                    StyledText {
                        id: tabLabel

                        anchors.centerIn: parent
                        text: tab.modelData.substring(tab.modelData.lastIndexOf("/") + 1) || "/"
                        font.pixelSize: 15
                    }
                }
            }
        }

        Rectangle {
            id: divider

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: tabs.bottom
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            height: 2
            color: Theme.magenta
        }

        GridView {
            id: grid

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: divider.bottom
            anchors.bottom: pathRow.top
            anchors.margins: 10
            clip: true
            cellWidth: Math.floor(width / 4)
            cellHeight: Math.floor(cellWidth * 0.62)
            boundsBehavior: Flickable.StopAtBounds
            Controls.ScrollBar.vertical: FrameScrollBar {}

            model: FolderListModel {
                folder: root.folders.length ? "file://" + root.folders[Math.min(root.folderIndex, root.folders.length - 1)] : ""
                nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.bmp", "*.PNG", "*.JPG", "*.JPEG"]
                showDirs: false
                sortField: FolderListModel.Name
            }

            delegate: MouseArea {
                id: thumb

                required property string filePath

                width: grid.cellWidth
                height: grid.cellHeight
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.apply(filePath)

                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    source: "file://" + thumb.filePath
                    sourceSize: Qt.size(width * 2, height * 2)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                // Plain border: the theme frames have a filled center that would hide the thumbnail
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    color: "transparent"
                    border.width: 2
                    border.color: thumb.filePath === Settings.wallpaper ? Theme.pink : Theme.lavender
                    visible: thumb.filePath === Settings.wallpaper || thumb.containsMouse
                }
            }

            StyledText {
                anchors.centerIn: parent
                visible: grid.count === 0
                text: "No images in this folder"
                color: Theme.textDim
            }
        }

        Item {
            id: pathRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 12
            height: 34

            Frame {
                anchors.left: parent.left
                anchors.right: applyButton.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                kind: "lineedit"

                TextInput {
                    id: pathInput

                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.textBright
                    selectionColor: Theme.magenta
                    font.family: Theme.font
                    font.pixelSize: 14
                    clip: true
                    focus: true
                    onAccepted: root.apply(text)
                }
            }

            FrameButton {
                id: applyButton

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 90
                height: 32
                normalFrame: "button-normal"
                hoverFrame: "button-hover"
                pressedFrame: "button-pressed"
                onClicked: root.apply(pathInput.text)

                StyledText {
                    anchors.centerIn: parent
                    text: "Apply"
                    color: Theme.textBright
                }
            }
        }
    }
}
