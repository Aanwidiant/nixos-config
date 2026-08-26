pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Singleton {
    id: root

    property bool isIdleActive: false

    Component.onCompleted: checkStatus()

    function checkStatus() {
        if (!checkProcess.running)
            checkProcess.running = true
    }

    function toggle() {
        if (!toggleProcess.running)
            toggleProcess.running = true
    }

    Process {
        id: checkProcess

        command: ["systemctl", "--user", "is-active", "--quiet", "swayidle"]

        onExited: (exitCode) => {
            root.isIdleActive = (exitCode === 0)
        }
    }

    Process {
        id: toggleProcess

        command: [
            "bash", "-c", `
                if systemctl --user is-active --quiet swayidle; then
                    systemctl --user stop swayidle
                    notify-send \
                        -a "System" \
                        -i "${Theme.nixosIcon}" \
                        "Idle Inhibitor" \
                        "Disabled · Locking & idle actions inactive"
                else
                    systemctl --user start swayidle
                    notify-send \
                        -a "System" \
                        -i "${Theme.nixosIcon}" \
                        "Idle Inhibitor" \
                        "Enabled · Locking & idle actions active"
                fi
            `
        ]

        onExited: () => {
            root.checkStatus()
        }
    }
}
