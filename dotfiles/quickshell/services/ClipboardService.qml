pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var historyList: []

    Component.onCompleted: refresh()

    function refresh() {
        fetchProcess.stdout.tempLines = []
        fetchProcess.running = true
    }

    function selectAndPaste(rawItem, closeCallback) {
        if (!rawItem) return;
        copyToClipboard(rawItem);
        if (typeof closeCallback === "function") {
            closeCallback();
        }
    }

    function copyToClipboard(rawItem) {
        if (!rawItem) return;
        const id = getId(rawItem);
        if (!id) return;

        copyProcess.clipId = id;
        copyProcess.running = true;
    }

    function getId(rawItem) {
        if (!rawItem) return "";
        let parts = rawItem.split("\t");
        return parts[0] || "";
    }

    function getDisplayText(rawItem) {
        if (!rawItem) return "";
        let parts = rawItem.split("\t");
        return parts.length > 1 ? parts.slice(1).join("\t") : rawItem;
    }

    function getDecodeCommand(rawItem, targetPath) {
        const id = getId(rawItem);
        if (!id) return "true";
        return `cliphist decode ${id} > ${targetPath}`;
    }

    function isImage(rawItem) {
        if (!rawItem) return false;
        return rawItem.includes("[[ binary data") || rawItem.match(/\.(png|jpg|jpeg|webp|gif)/i);
    }

    Process {
        id: fetchProcess
        command: ["cliphist", "list"]
        stdout: SplitParser {
            property var tempLines: []
            onRead: (data) => {
                if (data.trim() !== "") {
                    tempLines.push(data.trim())
                }
            }
        }
        onExited: {
            root.historyList = fetchProcess.stdout.tempLines
            fetchProcess.stdout.tempLines = []
        }
    }

    Process {
        id: copyProcess
        property string clipId: ""
        command: ["bash", "-c", `cliphist decode ${copyProcess.clipId} | wl-copy`]
    }
}
