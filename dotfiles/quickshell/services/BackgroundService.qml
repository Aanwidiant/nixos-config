pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var backgroundsList: []

    Component.onCompleted: refresh()

    function refresh() {
        fetchProcess.stdout.tempLines = []
        fetchProcess.running = true
    }

    function selectBackground(path, closeCallback) {
        if (!path) return;

        Quickshell.execDetached(["my-theme-bg-set", path]);

        if (typeof closeCallback === "function") {
            closeCallback();
        }
    }

    Process {
        id: fetchProcess
        command: ["bash", "-c", "find -L \"$HOME/.config/theme/backgrounds\" -type f \\( -name \"*.png\" -o -name \"*.jpg\" -o -name \"*.jpeg\" -o -name \"*.webp\" \\) | sort"]

        stdout: SplitParser {
            property var tempLines: []
            onRead: (data) => {
                if (data.trim() !== "") {
                    tempLines.push(data.trim())
                }
            }
        }

        onExited: {
            root.backgroundsList = fetchProcess.stdout.tempLines
            fetchProcess.stdout.tempLines = []
        }
    }
}
