pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var themesList: []

    Component.onCompleted: refresh()

    function refresh() {
        fetchProcess.stdout.tempLines = []
        fetchProcess.running = true
    }

    function selectTheme(themePath, closeCallback) {
        if (!themePath) return;

        const themeName = themePath.split("/").pop();

        Quickshell.execDetached(["my-theme-set", themeName]);

        if (typeof closeCallback === "function") {
            closeCallback();
        }
    }

    Process {
        id: fetchProcess
        command: ["bash", "-c", "find \"$HOME/.config/theme/themes/\" -mindepth 1 -maxdepth 1 \\( -type d -o -type l \\) | sort"]

        stdout: SplitParser {
            property var tempLines: []
            onRead: (data) => {
                if (data.trim() !== "") {
                    tempLines.push(data.trim())
                }
            }
        }

        onExited: {
            root.themesList = fetchProcess.stdout.tempLines
            fetchProcess.stdout.tempLines = []
        }
    }
}
