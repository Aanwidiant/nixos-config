pragma Singleton
import QtQuick 
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isIdleActive: false

    Component.onCompleted: checkStatus()

    function checkStatus() {
        checkProcess.running = true
    }

    function toggle() {
        toggleProcess.running = true
    }

    Process {
        id: checkProcess
        command: ["pgrep", "-x", "swayidle"]
        onExited: (exitCode) => {
            root.isIdleActive = (exitCode === 0)
        }
    }

    Process {
        id: toggleProcess
        command: ["bash", "-c", `
        if pgrep -x swayidle >/dev/null; then
        pkill -x swayidle
        notify-send "Stop locking computer when idle"
        else
        swayidle -w -C "$HOME/.config/swayidle/config" >/dev/null 2>&1 &
        notify-send "Now locking computer when idle"
        fi
        `]
        onExited: {
            root.checkStatus()
        }
    }
}
