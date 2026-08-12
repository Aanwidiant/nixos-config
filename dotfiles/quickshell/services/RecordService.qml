pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string selectedMode: "fullscreen"
    property string selectedAudio: "desktop"
    property int selectedFps: 60

    property bool isRecording: false
    property int durationSeconds: 0
    property bool isStarting: false

    readonly property string formattedTime: {
        let hrs = Math.floor(durationSeconds / 3600);
        let mins = Math.floor((durationSeconds % 3600) / 60);
        let secs = durationSeconds % 60;
        let pad = (n) => (n < 10 ? "0" + n : n);

        return hrs > 0 
        ? pad(hrs) + ":" + pad(mins) + ":" + pad(secs)
        : pad(mins) + ":" + pad(secs);
    }

    Timer {
        id: startupTimer
        interval: 1000 
        repeat: false
        onTriggered: root.isStarting = false
    }

    Process {
        id: checkProcess
        command: ["pgrep", "-x", "wf-recorder"]
        onExited: (code) => {
            let running = (code === 0);

            if (root.isStarting) return;

            if (!running && root.isRecording) {
                root.stopRecordingState();
            } else if (running && !root.isRecording) {
                root.startRecordingState();
            }
        }
    }

    Timer {
        id: recordTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            root.durationSeconds++;
            checkProcess.running = true;    
        }
    }

    Component.onCompleted: {
        checkProcess.running = true;
    }

    function startRecordingState() {
        root.isRecording = true;
        recordTimer.running = true;
    }

    function stopRecordingState() {
        root.isRecording = false;
        recordTimer.running = false;
        root.durationSeconds = 0;
        root.isStarting = false;
        startupTimer.stop();
    }

    function startRecording() {
        if (root.isRecording || root.isStarting) return;

        root.isStarting = true;
        startRecordingState();
        startupTimer.restart();

        Quickshell.execDetached([
            "my-cmd-screenrecord", root.selectedMode, root.selectedAudio, root.selectedFps.toString()
        ]);
    }

    function stopRecording() {
        if (!root.isRecording) return;

        Quickshell.execDetached(["pkill", "-INT", "wf-recorder"]);
        stopRecordingState();
    }
}
