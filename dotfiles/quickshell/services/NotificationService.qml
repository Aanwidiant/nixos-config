pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    signal notificationReceived(var notification)
    signal notificationDismissed(var notification)
    signal allCleared()

    readonly property alias server: server
    readonly property alias trackedNotifications: server.trackedNotifications
    readonly property ListModel history: ListModel {}

    property int activeCount: 0
    readonly property int historyCount: history.count

    property int defaultTimeoutMs: 5000

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            root.history.insert(0, {
                "summary": n.summary,
                "body": n.body,
                "appName": n.appName,
                "urgency": n.urgency,
                "image": n.image || n.appIcon || "",
                "time": Qt.formatDateTime(new Date(), "HH:mm")
            })

            n.tracked = true
            
            root.activeCount++

            n.closed.connect(() => {
                if (root.activeCount > 0) root.activeCount--
            })

            root.notificationReceived(n)

            if (n.urgency === NotificationUrgency.Critical) return

            let timeout = n.expireTimeout > 0 ? n.expireTimeout : root.defaultTimeoutMs

            if (timeout > 0) {
                root.scheduleTimerNotification(n, timeout)
            }
        }
    }

    function getListHistory() {
        let list = []
        for (let i = 0; i < history.count; i++) {
            list.push(history.get(i))
        }
        return list
    }

    function removeHistory(index) {
        if (index >= 0 && index < history.count) {
            history.remove(index)
        }
    }

    function removeAllHistory() {
        history.clear()
        root.allCleared()
    }

    function dismissNotification(notification) {
        if (notification) {
            notification.dismiss()
            root.notificationDismissed(notification)
        }
    }

    function scheduleTimerNotification(notification, delayMs) {
        let timer = Qt.createQmlObject('import QtQuick; Timer {}', root)
        timer.interval = delayMs || root.defaultTimeoutMs
        timer.repeat = false
        timer.triggered.connect(() => {
            root.dismissNotification(notification)
            timer.destroy()
        })
        timer.start()
    }
}
