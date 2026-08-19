pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Singleton {
    id: root

    property bool isTouchpadActive: true

    Component.onCompleted: initFromConfig()

    function initFromConfig() {
        initProcess.running = true
    }

    function toggle() {
        root.isTouchpadActive = !root.isTouchpadActive
        toggleProcess.running = true
    }

    Process {
        id: notifyProcess
        property string message: ""

        command: [
            "notify-send",
            "-i", Theme.nixosIcon,
            "Touchpad",
            message
        ]
    }

    Process {
        id: initProcess

        command: ["bash", "-c", `
            grep -E '^disable_trackpad=' "$HOME/.config/mango/config.conf" 2>/dev/null | tail -n1 | cut -d= -f2
        `]

        stdout: SplitParser {
            onRead: (data) => {
                const val = data.trim()
                root.isTouchpadActive = (val !== "1")
            }
        }
    }

    Process {
        id: toggleProcess

        command: ["mmsg", "dispatch", "toggle_trackpad_enable"]

        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.isTouchpadActive = !root.isTouchpadActive
                notifyProcess.message = "Toggle failed"
            } else {
                notifyProcess.message = root.isTouchpadActive
                    ? "Enabled · Touchpad is active"
                    : "Disabled · Touchpad is disabled"
            }

            notifyProcess.running = true
        }
    }
}
