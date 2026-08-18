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
    property bool isPaused: false
    property int durationSeconds: 0
    property bool isStarting: false
    property bool isStopping: false

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
        onTriggered: {
            root.isStarting = false;
            checkProcess.running = true;
        }
    }

    Timer {
        id: stopPollTimer
        interval: 500
        repeat: true
        running: root.isStopping && !root.isStarting
        onTriggered: {
            checkProcess.running = true;
        }
    }

    Process {
        id: checkProcess
        command: ["pgrep", "-f", "gpu-screen-recorder"]
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
            if (!root.isPaused) {
                root.durationSeconds++;
                checkProcess.running = true;  // cek proses hanya saat tidak pause
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 1000
        running: !root.isRecording && !root.isStarting
        repeat: true
        onTriggered: checkProcess.running = true
    }

    Component.onCompleted: {
        checkProcess.running = true;
    }

    function startRecordingState() {
        root.isRecording = true;
        root.isPaused = false;
        recordTimer.running = true;
    }

    function stopRecordingState() {
        root.isRecording = false;
        root.isPaused = false;
        root.isStopping = false;
        recordTimer.running = false;
        root.durationSeconds = 0;
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

    function togglePause() {
        if (!root.isRecording || root.isStarting) return;
        root.isStarting = true;
        root.isPaused = !root.isPaused;
        Quickshell.execDetached(["my-cmd-screenrecord", "toggle-pause"]);
        startupTimer.restart();
    }   

    function stopRecording() {
        if (!root.isRecording || root.isStopping) return;
        root.isStopping = true;
        root.isStarting = true;
        recordTimer.running = false;
        Quickshell.execDetached(["my-cmd-screenrecord", "stop"]);
        startupTimer.restart();
    }
}
