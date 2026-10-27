pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// settings.json next to the Hyprland config. install.sh writes the first version,
// the shell keeps it updated (wallpaper picker, launcher favorites).
Singleton {
    id: root

    readonly property string configDir: Quickshell.env("YUNYUN_CONFIG_DIR") || (Quickshell.env("HOME") + "/.config/yunyun-syndrome")

    property alias wallpaper: adapter.wallpaper
    property alias wallpaperDirs: adapter.wallpaperDirs
    property alias favorites: adapter.favorites
    property alias favoritesInitialized: adapter.favoritesInitialized
    property alias visualizer: adapter.visualizer
    property alias desktopDecorations: adapter.desktopDecorations
    property alias clock24h: adapter.clock24h

    function toggleFavorite(id) {
        const list = [...favorites];
        const i = list.indexOf(id);
        if (i >= 0)
            list.splice(i, 1);
        else
            list.push(id);
        favorites = list;
    }

    FileView {
        path: root.configDir + "/settings.json"
        // Load before anything reads the settings, so defaults never overwrite the file
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter

            property string wallpaper: ""
            property list<string> wallpaperDirs: []
            property list<string> favorites: []
            property bool favoritesInitialized: false
            property bool visualizer: true
            property bool desktopDecorations: true
            property bool clock24h: true
        }
    }
}
