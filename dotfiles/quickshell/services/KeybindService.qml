pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var bindingsList: []

    Component.onCompleted: refresh()

    function refresh() {
        fetchProcess.stdout.tempLines = []
        fetchProcess.running = true
    }

    function getKey(rawItem) {
        if (!rawItem) return "";
        let parts = rawItem.trim().split(/\t|\s{2,}/);
        return parts.length > 1 ? parts[0].trim() : "";
    }

    function getDescription(rawItem) {
        if (!rawItem) return "";
        let parts = rawItem.trim().split(/\t|\s{2,}/);
        return parts.length > 1 ? parts.slice(1).join(" ").trim() : rawItem.trim();
    }

    function selectItem(rawItem, closeCallback) {
        if (!rawItem) return;
        if (typeof closeCallback === "function") {
            closeCallback();
        }
    }

    Process {
        id: fetchProcess
        command: ["bash", "-c", "grep -v '^#' ${XDG_CONFIG_HOME:-$HOME/.config}/mango/bindings.txt | grep -v '^\\s*$'"]

        stdout: SplitParser {
            property var tempLines: []
            onRead: (data) => {
                if (data.trim() !== "") {
                    tempLines.push(data.trim())
                }
            }
        }

        onExited: {
            root.bindingsList = fetchProcess.stdout.tempLines
            fetchProcess.stdout.tempLines = []
        }
    }
}
