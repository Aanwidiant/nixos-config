pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root

    property var monitorsByName: ({})

    Component.onCompleted: fetchInitialState()

    function fetchInitialState() {
        initialFetchProc.running = false
        initialFetchProc.running = true
    }

    function parseMonitorsData(parsed) {
        if (!parsed || !Array.isArray(parsed.monitors)) return
        let map = {}
        for (const mon of parsed.monitors) {
            if (mon && mon.name) map[mon.name] = mon
        }
        root.monitorsByName = map
    }

    Process {
        id: initialFetchProc
        command: ["mmsg", "get", "all-monitors"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const raw = data.trim()
                if (!raw) return
                try { parseMonitorsData(JSON.parse(raw)) } catch (err) {}
            }
        }
    }

    Process {
        id: monitorWatcher
        command: ["mmsg", "watch", "all-monitors"]
        running: true
        onExited: restartTimer.start()
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const raw = data.trim()
                if (!raw) return
                try { parseMonitorsData(JSON.parse(raw)) } catch (err) {}
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        repeat: false
        onTriggered: if (!monitorWatcher.running) monitorWatcher.running = true
    }

    Process { id: dispatchProc }

    function switchTag(monitorName, tagIndex) {
        const t = Number(tagIndex)
        dispatchProc.running = false
        dispatchProc.command = ["mmsg", "dispatch", "viewcrossmon," + t + "," + monitorName]
        dispatchProc.running = true
    }
}
