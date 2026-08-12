pragma Singleton
import QtQuick
import Quickshell

Item {
    id: root

    property int customHours: 0
    property int customMins: 0
    property int customSecs: 0
    readonly property int totalCustomSeconds: (customHours * 3600) + (customMins * 60) + customSecs

    function setPreset(secs) {
        customHours = Math.floor(secs / 3600);
        const rem = secs % 3600;
        customMins = Math.floor(rem / 60);
        customSecs = rem % 60;
    }

    function addHours(delta) {
        customHours = Math.max(0, Math.min(99, customHours + delta));
    }

    function addMins(delta) {
        customMins = Math.max(0, Math.min(59, customMins + delta));
    }

    function addSecs(delta) {
        customSecs = Math.max(0, Math.min(59, customSecs + delta));
    }

    function resetCustomPicker() {
        customHours = 0;
        customMins = 0;
        customSecs = 0;
    }

    property bool swRunning: false
    property int swSeconds: 0

    readonly property string swFormatted: formatStopwatch(swSeconds)
    readonly property bool swCanReset: !swRunning && swSeconds > 0

    Timer {
        id: swTimer
        interval: 1000
        repeat: true
        running: root.swRunning
        onTriggered: root.swSeconds++
    }

    function swToggle() { root.swRunning = !root.swRunning; }
    function swReset() {
        if (swRunning) {
            return; 
        }
        root.swRunning = false;
        root.swSeconds = 0;
    }

    property bool tmRunning: false
    property int tmRemaining: 0
    property int tmTotal: 0

    readonly property string tmFormatted: formatTime(tmRemaining)
    readonly property real tmProgress: tmTotal > 0 ? (tmRemaining / tmTotal) : 0

    Timer {
        id: tmTimer
        interval: 1000
        repeat: true
        running: root.tmRunning
        onTriggered: {
            if (root.tmRemaining > 0) {
                root.tmRemaining--;
            } else {
                root.tmRunning = false;
                root.triggerTimerAlert();
            }
        }
    }

    function tmStartCustom() {
        if (root.totalCustomSeconds > 0) {
            root.tmSetAndStart(root.totalCustomSeconds);
            root.resetCustomPicker();
        }
    }

    function tmSetAndStart(seconds) {
        root.tmTotal = seconds;
        root.tmRemaining = seconds;
        root.tmRunning = true;
    }

    function tmToggle() {
        if (root.tmRemaining > 0) {
            root.tmRunning = !root.tmRunning;
        }
    }

    function tmReset() {
        if (tmRunning) {
            return; 
        }
        root.tmRunning = false;
        root.tmRemaining = 0;
        root.tmTotal = 0;
    }

    function triggerTimerAlert() {
        Quickshell.execDetached([
            "bash", "-c",
            "notify-send 'Timer Finished!' \"Time's up!\" -u critical && (canberra-gtk-play -i alarm-clock-elapsed || pw-play /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga)"
        ]);
    }

    function formatTime(totalSecs) {
        let hrs = Math.floor(totalSecs / 3600);
        let mins = Math.floor((totalSecs % 3600) / 60);
        let secs = totalSecs % 60;
        let pad = (n) => (n < 10 ? "0" + n : n);

        return hrs > 0 
        ? `${pad(hrs)}:${pad(mins)}:${pad(secs)}`
        : `${pad(mins)}:${pad(secs)}`;
    }

    function formatStopwatch(totalSecs) {
        let hrs = Math.floor(totalSecs / 3600);
        let mins = Math.floor((totalSecs % 3600) / 60);
        let secs = totalSecs % 60;
        let pad = (n) => (n < 10 ? "0" + n : n);

        return `${pad(hrs)}:${pad(mins)}:${pad(secs)}`;
    }
}
