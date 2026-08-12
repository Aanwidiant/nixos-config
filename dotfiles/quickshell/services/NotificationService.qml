pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications as Notifs

Item {
    id: root

    property int defaultTimeout: 5000
    property int maxNotifications: 20

    // Sinyal untuk IslandController
    signal notificationReceived()
    signal allCleared()

    Notifs.NotificationServer {
        id: server
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        keepOnReload: false

        onNotification: function(notification) {
            notification.tracked = true

            // Anti-spam: jika dari app yang sama, ganti yang lama
            if (count > 1) {
                const prev = server.trackedNotifications.get(count - 2)
                if (prev && prev.appName === notification.appName) {
                    prev.dismiss()
                }
            }

            root._enforceMax()
            root.notificationReceived() // ← Trigger controller
        }
    }

    readonly property var notifications: server.trackedNotifications
    readonly property int count: server.trackedNotifications.count
    readonly property var current: count > 0 ? server.trackedNotifications.get(0) : null

    function dismissCurrent() {
        if (count > 0) {
            server.trackedNotifications.get(0).dismiss()
        }
    }

    function dismiss(index) {
        if (index >= 0 && index < count) {
            server.trackedNotifications.get(index).dismiss()
        }
    }

    function clearAll() {
        for (let i = count - 1; i >= 0; i--) {
            server.trackedNotifications.get(i).dismiss()
        }
        root.allCleared()
    }

    function _enforceMax() {
        while (count > maxNotifications) {
            server.trackedNotifications.get(0).dismiss()
        }
    }
}
