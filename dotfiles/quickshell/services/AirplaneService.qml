pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Singleton {
    id: root

    property bool isAirplaneActive: false
    property bool shouldNotifyAfterCheck: false

    Component.onCompleted: checkStatus()

    function checkStatus() {
        checkProcess.running = true
    }

    function toggle() {
        root.shouldNotifyAfterCheck = true
        toggleProcess.running = true
    }

    Process {
        id: notifyProcess

        property string message: ""

        command: [
            "notify-send",
            "-i", Theme.nixosIcon,
            "Airplane Mode",
            message
        ]
    }

    Process {
        id: checkProcess

        command: ["bash", "-c", `
            wifi_blocked=$(rfkill list wifi | grep -q "Soft blocked: yes" && echo yes || echo no)
            bt_blocked=$(rfkill list bluetooth | grep -q "Soft blocked: yes" && echo yes || echo no)

            if [ "$wifi_blocked" = "yes" ] && [ "$bt_blocked" = "yes" ]; then
                echo "active"
            else
                echo "inactive"
            fi
        `]

        stdout: SplitParser {
            onRead: (data) => {
                let status = data.trim()
                root.isAirplaneActive = (status === "active")
            }
        }

        onExited: {
            if (root.shouldNotifyAfterCheck) {
                root.shouldNotifyAfterCheck = false

                notifyProcess.message = root.isAirplaneActive
                    ? "Enabled · Wireless connections blocked"
                    : "Disabled · Wireless connections available"

                notifyProcess.running = true
            }
        }
    }

    Process {
        id: toggleProcess

        command: ["bash", "-c", `
            wifi_blocked=$(rfkill list wifi | grep -q "Soft blocked: yes" && echo yes || echo no)
            bt_blocked=$(rfkill list bluetooth | grep -q "Soft blocked: yes" && echo yes || echo no)

            if [ "$wifi_blocked" = "yes" ] && [ "$bt_blocked" = "yes" ]; then
                rfkill unblock wifi
                rfkill unblock bluetooth
            else
                rfkill block wifi
                rfkill block bluetooth
            fi
        `]

        onExited: {
            root.checkStatus()
        }
    }
}
