pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string lastColor: "#ffffff"
    property bool hasColor: false

    Process {
        id: pickerProcess
        command: ["hyprpicker", "-a"]

        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim();
                if (trimmed.startsWith("#") || trimmed.length === 6) {
                    root.lastColor = trimmed.startsWith("#") ? trimmed : "#" + trimmed;
                    root.hasColor = true;
                }
            }
        }
    }

    Timer {
        id: delayTimer
        interval: 175 
        repeat: false
        onTriggered: {
            if (!pickerProcess.running) {
                pickerProcess.running = true;
            }
        }
    }

    function pickColor() {
        delayTimer.restart();
    }
}
