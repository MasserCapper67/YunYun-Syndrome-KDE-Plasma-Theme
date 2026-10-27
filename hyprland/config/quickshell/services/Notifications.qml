pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon. Popups show every tracked notification until it expires or is dismissed.
Singleton {
    id: root

    readonly property var list: server.trackedNotifications.values

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: false

        onNotification: notification => notification.tracked = true
    }
}
