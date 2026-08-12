pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var spectrum: []
    property int barCount: 6
    property bool initialized: false

    property int activeConsumers: 0 
    property int stopDelay: 5000 

    signal spectrumUpdated()

    Timer {
        id: stopTimer
        interval: root.stopDelay
        repeat: false
        onTriggered: {
            if (root.activeConsumers === 0) {
                cavaProcess.running = false
            }
        }
    }

    Process {
        id: cavaProcess
        command: ["cava", "-p", `${Quickshell.env("HOME")}/.config/cava/quickshell_config`]

        running: false 

        stdout: SplitParser {
            onRead: data => {
                if (root.activeConsumers === 0) return

                var cleanData = data.trim()
                if (cleanData.endsWith(";")) {
                    cleanData = cleanData.slice(0, -1)
                }

                var rawValues = cleanData.split(";")
                var parsed = []

                for (var i = 0; i < rawValues.length; i++) {
                    var val = parseInt(rawValues[i])
                    if (!isNaN(val)) {
                        parsed.push(val)
                    }
                }

                if (parsed.length > 0) {
                    root.spectrum = parsed
                    root.barCount = parsed.length

                    if (!root.initialized) {
                        root.initialized = true
                    }

                    root.spectrumUpdated()
                }
            }
        }
    }

    function getBarHeight(index) {
        if (index < root.spectrum.length) {
            return root.spectrum[index] / 100
        }
        return 0
    }

    function setActive(isActive) {
        if (isActive) {
            root.activeConsumers++
            stopTimer.stop()

            if (!cavaProcess.running) {
                cavaProcess.running = true
            }
        } else {
            root.activeConsumers = Math.max(0, root.activeConsumers - 1)

            if (root.activeConsumers === 0) {
                stopTimer.restart()
            }
        }
    }
}
