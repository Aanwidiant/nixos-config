pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root

    property real brightness: 0
    property int maxBrightness: -1
    property bool initialized: false
    property string backlightDevice: "intel_backlight" 

    signal brightnessUpdated()

    Process {
        id: maxProc
        command: ["cat", `/sys/class/backlight/${root.backlightDevice}/max_brightness`]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(text.trim())
                if (!isNaN(val) && val > 0) {
                    root.maxBrightness = val
                    getBrightness()
                }
            }
        }
    }

    Process {
        id: brightnessProc
        command: ["cat", `/sys/class/backlight/${root.backlightDevice}/brightness`]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(text.trim())
                if (isNaN(val) || root.maxBrightness === -1) return

                var brightnessPercent = val / root.maxBrightness

                if (!root.initialized) {
                    root.brightness = brightnessPercent
                    root.initialized = true
                    return
                }

                if (Math.abs(brightnessPercent - root.brightness) > 0.001) {
                    root.brightness = brightnessPercent
                    root.brightnessUpdated()
                }
            }
        }
    }

    function getBrightness() {
        brightnessProc.running = true
    }

    function setBrightness(value) {
        if (root.maxBrightness === -1) {
            return
        }

        var percent = Math.round(value * 100)

        percent = Math.max(0, Math.min(100, percent))

        setProc.command = ["brightnessctl", "set", percent + "%"]
        setProc.running = true
    }

    function increase(step) {
        if (!root.initialized) return
        setBrightness(root.brightness + step)
    }

    function decrease(step) {
        if (!root.initialized) return
        setBrightness(root.brightness - step)
    }

    Process {
        id: setProc
        running: false

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                getBrightness() 
            } else {
                console.error("[BrightnessService] Failed to set brightness. Exit code:", exitCode)
            }
        }
    }

    Component.onCompleted: {
        getBrightness()
    }

    function getBrightnessIcon(level) {
        if (level === 0) return "\udb80\udcdd"
        if (level < 33) return "\udb80\udcde"
        if (level < 66) return "\udb80\udcdf"
        return "\udb80\udce0"
    }
}
