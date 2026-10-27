import QtQuick
import Quickshell
import Quickshell.Widgets

// An icon from the icon theme (Candy icons), by name or path, with a fallback.
IconImage {
    property string name: ""
    property string fallback: "application-x-executable"

    implicitSize: 16
    source: {
        if (!name)
            return Quickshell.iconPath(fallback, true);
        if (name.startsWith("/") || name.startsWith("file:") || name.startsWith("image:"))
            return name;
        return Quickshell.iconPath(name, fallback);
    }
}
