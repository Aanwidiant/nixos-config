pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root

    property string activeMonitorName: ""
    property var monitorsData: []

    Process {
        id: mmsgProcess
        command: ["mmsg", "watch", "all-monitors"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data)
                    if (parsed && parsed.monitors) {
                        root.monitorsData = parsed.monitors
                        
                        var activeMon = parsed.monitors.find(m => m.active === true)
                        if (activeMon) {
                            root.activeMonitorName = activeMon.name
                        }
                    }
                } catch (e) {
                    // 
                }
            }
        }
    }
}
