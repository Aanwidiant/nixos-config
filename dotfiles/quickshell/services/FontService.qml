pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var fontsList: []

    Component.onCompleted: refresh()

    function refresh() {
        fetchProcess.stdout.tempLines = []
        fetchProcess.running = true
    }

    function selectFont(fontName, closeCallback) {
        if (!fontName) return;


        Quickshell.execDetached(["my-font-set", fontName]);

        if (typeof closeCallback === "function") {
            closeCallback();
        }
    }

    Process {
        id: fetchProcess
        command: ["bash", "-c", "fc-list :spacing=100 -f '%{family[0]}\\n' | grep -v -i -E 'emoji|signwriting' | sort -u"]

        stdout: SplitParser {
            property var tempLines: []
            onRead: (data) => {
                if (data.trim() !== "") {
                    tempLines.push(data.trim())
                }
            }
        }

        onExited: {
            root.fontsList = fetchProcess.stdout.tempLines
            fetchProcess.stdout.tempLines = []
        }
    }
}
