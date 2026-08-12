pragma Singleton  
import QtQuick
import Quickshell.Io

Item {
    id: root

    property string activeMonitorName: ""
    property var activeTagsList: []
    property var occupiedTagsList: []

    Process {
        id: monitorWatcher
        command: ["mmsg", "watch", "all-monitors"]
        running: true

        onExited: restartTimer.start()

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                let raw = data.trim();
                if (!raw) return;

                try {
                    let parsed = JSON.parse(raw);
                    if (parsed && Array.isArray(parsed.monitors) && parsed.monitors.length > 0) {
                        let activeMon = parsed.monitors.find(m => m.active === true) || parsed.monitors[0];
                        if (activeMon) {
                            root.activeMonitorName = activeMon.name || root.activeMonitorName;
                            root.activeTagsList = Array.isArray(activeMon.active_tags) ? activeMon.active_tags : root.activeTagsList;
                        }
                    }
                } catch (err) {}
            }
        }
    }

    Process {
        id: clientWatcher
        command: ["mmsg", "watch", "all-clients"]
        running: true

        onExited: restartTimer.start()

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                let raw = data.trim();
                if (!raw) return;

                try {
                    let parsed = JSON.parse(raw);
                    if (parsed && Array.isArray(parsed.clients)) {
                        let occupiedSet = new Set();

                        for (let i = 0; i < parsed.clients.length; i++) {
                            let c = parsed.clients[i];
                            if (c && c.monitor === root.activeMonitorName && Array.isArray(c.tags)) {
                                for (let j = 0; j < c.tags.length; j++) {
                                    occupiedSet.add(Number(c.tags[j]));
                                }
                            }
                        }

                        root.occupiedTagsList = Array.from(occupiedSet);
                    }
                } catch (err) {}
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (!monitorWatcher.running) monitorWatcher.running = true;
            if (!clientWatcher.running) clientWatcher.running = true;
        }
    }

    Process {
        id: dispatchProc
    }

    function switchTag(tagIndex) {
        let targetNum = Number(tagIndex);
        root.activeTagsList = [targetNum];

        dispatchProc.running = false;
        dispatchProc.command = ["mmsg", "dispatch", "view," + targetNum.toString()];
        dispatchProc.running = true;
    }
}
