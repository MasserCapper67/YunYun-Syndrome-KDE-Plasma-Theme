import QtQuick
import QtQuick.Controls.Basic as Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

// Application launcher modelled on the KDE start menu in the screenshots:
// user + search on top, categories on the left, app grid on the right, power at the bottom.
PopupSurface {
    id: root

    popupName: "launcher"

    property string category: "favorites"
    property string query: ""
    readonly property bool searching: query.trim() !== ""
    readonly property var entries: {
        if (searching)
            return Apps.search(query);
        if (category === "favorites")
            return Apps.byIds(Settings.favorites);
        if (category === "all")
            return Apps.all;
        return Apps.byCategory(category);
    }

    function launch(entry) {
        Apps.launch(entry);
        ShellState.close();
    }

    onVisibleChanged: {
        if (visible) {
            query = "";
            search.text = "";
            category = "favorites";
            search.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        if (!Settings.favoritesInitialized) {
            Settings.favorites = Apps.defaultFavorites();
            Settings.favoritesInitialized = true;
        }
    }

    Frame {
        id: panel

        x: 0
        y: 0
        width: 725
        height: 596
        kind: "dialog"

        // Swallow clicks so they don't reach the close-on-click layer behind
        MouseArea {
            anchors.fill: parent
        }

        // Header: avatar, user name, search
        Item {
            id: headerRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: panel.padTop
            height: 46

            ClippingRectangle {
                id: avatar

                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 30
                height: 30
                radius: 15
                color: Theme.panel

                Image {
                    anchors.fill: parent
                    source: "file://" + Quickshell.env("HOME") + "/.face"
                    sourceSize: Qt.size(60, 60)
                    fillMode: Image.PreserveAspectCrop
                    onStatusChanged: if (status === Image.Error) source = Theme.asset("icons/start.svg")
                }
            }

            StyledText {
                anchors.left: avatar.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 200
                text: userName.text.trim() || Quickshell.env("USER")
                color: Theme.textBright
                font.pixelSize: 16
            }

            Process {
                running: true
                command: ["sh", "-c", "getent passwd \"$USER\" | cut -d: -f5 | cut -d, -f1"]
                stdout: StdioCollector {
                    id: userName
                }
            }

            Frame {
                id: searchFrame

                anchors.left: parent.left
                anchors.leftMargin: 266
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                kind: "lineedit"

                ThemedIcon {
                    id: searchIcon

                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: 14
                    name: "search"
                    fallback: "edit-find"
                }

                TextInput {
                    id: search

                    anchors.left: searchIcon.right
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.textBright
                    selectionColor: Theme.magenta
                    font.family: Theme.font
                    font.weight: Theme.fontWeight
                    font.pixelSize: 15
                    clip: true
                    focus: true
                    onTextChanged: {
                        root.query = text;
                        grid.currentIndex = 0;
                        results.currentIndex = 0;
                    }

                    Keys.onPressed: event => {
                        const view = root.searching ? results : grid;
                        switch (event.key) {
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            root.launch(root.entries[view.currentIndex]);
                            break;
                        case Qt.Key_Down:
                            root.searching ? results.incrementCurrentIndex() : grid.moveCurrentIndexDown();
                            break;
                        case Qt.Key_Up:
                            root.searching ? results.decrementCurrentIndex() : grid.moveCurrentIndexUp();
                            break;
                        case Qt.Key_Right:
                            if (root.searching || search.cursorPosition < search.text.length)
                                return;
                            grid.moveCurrentIndexRight();
                            break;
                        case Qt.Key_Left:
                            if (root.searching || search.text.length > 0)
                                return;
                            grid.moveCurrentIndexLeft();
                            break;
                        case Qt.Key_Escape:
                            ShellState.close();
                            break;
                        default:
                            return;
                        }
                        event.accepted = true;
                    }

                    StyledText {
                        anchors.fill: parent
                        text: "Search…"
                        color: Theme.textDim
                        font.pixelSize: 15
                        visible: search.text === ""
                    }
                }
            }
        }

        // Left: categories
        ListView {
            id: categoryList

            anchors.left: parent.left
            anchors.leftMargin: panel.padLeft + 2
            anchors.top: headerRow.bottom
            anchors.topMargin: 4
            anchors.bottom: powerBar.top
            anchors.bottomMargin: 4
            width: 258
            visible: !root.searching
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            Controls.ScrollBar.vertical: FrameScrollBar {}

            model: [
                { id: "favorites", name: "Favorites", icon: "starred", fallback: "emblem-favorite" },
                { id: "all", name: "All Applications", icon: "view-app-grid", fallback: "view-grid" },
                { id: "-" },
                ...Apps.categories
            ]

            delegate: Item {
                id: categoryItem

                required property var modelData
                readonly property bool separator: modelData.id === "-"
                readonly property bool current: !root.searching && root.category === modelData.id

                width: categoryList.width - 16
                height: separator ? 14 : 34

                Rectangle {
                    visible: categoryItem.separator
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 2
                    color: Theme.magenta
                }

                FrameButton {
                    id: categoryButton

                    visible: !categoryItem.separator
                    anchors.fill: parent
                    checked: categoryItem.current
                    hoverFrame: "viewitem-hover"
                    pressedFrame: "viewitem-selected"
                    // Hovering switches category, like Kickoff
                    onContainsMouseChanged: if (containsMouse) hoverSwitch.restart()
                    onClicked: root.category = categoryItem.modelData.id

                    Timer {
                        id: hoverSwitch
                        interval: 150
                        onTriggered: if (categoryButton.containsMouse && !root.searching) root.category = categoryItem.modelData.id
                    }

                    ThemedIcon {
                        id: categoryIcon

                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 22
                        name: categoryItem.modelData.icon ?? ""
                        fallback: categoryItem.modelData.fallback ?? "applications-other"
                    }

                    StyledText {
                        anchors.left: categoryIcon.right
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: categoryItem.modelData.name ?? ""
                        font.pixelSize: 16
                    }
                }
            }
        }

        Rectangle {
            anchors.left: categoryList.right
            anchors.leftMargin: 4
            anchors.top: categoryList.top
            anchors.bottom: categoryList.bottom
            width: 2
            color: Theme.magenta
            visible: !root.searching
        }

        // Right: app grid (browsing) or result list (searching)
        GridView {
            id: grid

            anchors.left: categoryList.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: panel.padRight + 4
            anchors.top: categoryList.top
            anchors.bottom: categoryList.bottom
            visible: !root.searching
            clip: true
            cellWidth: Math.floor(width / 4)
            cellHeight: 108
            boundsBehavior: Flickable.StopAtBounds
            keyNavigationWraps: true
            highlightFollowsCurrentItem: false
            Controls.ScrollBar.vertical: FrameScrollBar {}
            model: root.searching ? [] : root.entries

            delegate: AppTile {
                required property var modelData
                required property int index

                width: grid.cellWidth
                height: grid.cellHeight
                entry: modelData
                current: GridView.isCurrentItem
                favorite: Settings.favorites.includes(modelData.id)
                onActivated: root.launch(modelData)
                onToggleFavorite: Settings.toggleFavorite(modelData.id)
                onHoveredChanged: if (hovered) grid.currentIndex = index
            }

            StyledText {
                anchors.centerIn: parent
                visible: grid.count === 0
                width: parent.width - 40
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: root.category === "favorites" ? "Right-click an app to add it to Favorites" : "Nothing here"
                color: Theme.textDim
            }
        }

        ListView {
            id: results

            anchors.left: parent.left
            anchors.leftMargin: panel.padLeft + 2
            anchors.right: parent.right
            anchors.rightMargin: panel.padRight + 4
            anchors.top: categoryList.top
            anchors.bottom: categoryList.bottom
            visible: root.searching
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            Controls.ScrollBar.vertical: FrameScrollBar {}
            model: root.searching ? root.entries : []

            delegate: SearchResult {
                required property var modelData
                required property int index

                width: results.width - 14
                entry: modelData
                showSection: index === 0
                current: ListView.isCurrentItem
                onActivated: root.launch(modelData)
                onHoveredChanged: if (hovered) results.currentIndex = index
            }

            StyledText {
                anchors.centerIn: parent
                visible: results.count === 0
                text: "No results"
                color: Theme.textDim
            }
        }

        PowerBar {
            id: powerBar

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: panel.padLeft
            anchors.rightMargin: panel.padRight
            anchors.bottomMargin: panel.padBottom
            height: 46
        }
    }
}
