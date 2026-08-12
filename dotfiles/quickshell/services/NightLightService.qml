pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isNightLightActive: false
    property int onTemp: 4000

    Component.onCompleted: checkStatus()

    function checkStatus() {
        checkProcess.running = true
    }

    function toggle() {
        toggleProcess.running = true
    }

    Process {
        id: checkProcess
        command: ["pgrep", "-x", "wlsunset"]
        onExited: (exitCode) => {
            root.isNightLightActive = (exitCode === 0)
        }
    }

    Process {
        id: toggleProcess
        command: ["bash", "-c", `
        ON_TEMP=${root.onTemp}

        if pgrep -x wlsunset >/dev/null; then
        pkill -x wlsunset
        notify-send "  Daylight screen temperature"
        else
        setsid wlsunset -t "$ON_TEMP" -T "$((ON_TEMP + 1))" -l 90 -L 0 >/dev/null 2>&1 &
        notify-send "  Nightlight screen temperature"
        fi
        `]
        onExited: {
            root.checkStatus()
        }
    }
}
