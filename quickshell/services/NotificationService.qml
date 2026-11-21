pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
    id: root

    property var currentNotification: null
    property string appName: ""
    property string appIcon: ""
    property string image: ""
    property string summary: ""
    property string body: ""
    property int urgency: 1 // 0=Low, 1=Normal, 2=Critical
    property bool hasNotification: currentNotification !== null

    readonly property string iconOrImage: {
        if (image && image !== "") {
            if (image.indexOf("/") === 0) return "file://" + image
            return image
        }
        if (appIcon && appIcon !== "") {
            if (appIcon.indexOf("/") === 0) return "file://" + appIcon
            if (appIcon.indexOf("file://") === 0 || appIcon.indexOf("image://") === 0) return appIcon
            return "image://icon/" + appIcon
        }
        return ""
    }

    signal notificationReceived(var notif)

    NotificationServer {
        id: server
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: (notif) => {
            notif.tracked = true
            root.currentNotification = notif
            root.appName = (notif.appName && notif.appName !== "") ? notif.appName : "Sistema"
            root.appIcon = notif.appIcon || ""
            
            var img = ""
            if (notif.image) {
                img = String(notif.image)
            } else if (notif.hints) {
                if (notif.hints["image-path"]) img = String(notif.hints["image-path"])
                else if (notif.hints["image_path"]) img = String(notif.hints["image_path"])
            }
            root.image = img

            root.summary = notif.summary || ""
            root.body = notif.body || ""
            root.urgency = notif.urgency !== undefined ? notif.urgency : 1
            root.notificationReceived(notif)
        }
    }

    function dismissCurrent() {
        if (root.currentNotification) {
            try {
                root.currentNotification.tracked = false
                root.currentNotification.dismiss()
            } catch(e) {}
            root.currentNotification = null
        }
        root.hasNotification = false
        root.image = ""
        root.appIcon = ""
    }
}
