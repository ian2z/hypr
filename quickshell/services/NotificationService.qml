pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
    id: root

    property var currentNotification: null
    property string appName: ""
    property string appIcon: ""
    property string summary: ""
    property string body: ""
    property int urgency: 1 // 0=Low, 1=Normal, 2=Critical
    property bool hasNotification: currentNotification !== null

    signal notificationReceived(var notif)

    NotificationServer {
        id: server
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true

        onNotification: (notif) => {
            root.currentNotification = notif
            root.appName = (notif.appName && notif.appName !== "") ? notif.appName : "Sistema"
            root.appIcon = notif.appIcon || ""
            root.summary = notif.summary || ""
            root.body = notif.body || ""
            root.urgency = notif.urgency !== undefined ? notif.urgency : 1
            root.notificationReceived(notif)
        }
    }

    function dismissCurrent() {
        if (root.currentNotification) {
            try {
                root.currentNotification.dismiss()
            } catch(e) {}
            root.currentNotification = null
        }
        root.hasNotification = false
    }
}
