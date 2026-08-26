pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    signal finished()
    property var _queued: null
    property Process _proc: Process {
        running: false
        onExited: (code, status) => {
            root.finished();
            if (root._queued !== null) {
                let next = root._queued;
                root._queued = null;
                _proc.command = ["bash", "-c", next];
                _proc.running = true;
            }
        }
    }
    function exec(cmd: string) {
        if (_proc.running) {
            _queued = cmd;
            _proc.running = false; 
        } else {
            _proc.command = ["bash", "-c", cmd];
            _proc.running = true;
        }
    }

    function ensureSwayidleAndRun(actionCmd: string) {
        let cmd = "systemctl --user is-active swayidle >/dev/null 2>&1 || " +
        "{ systemctl --user start swayidle; sleep 0.5; }; " +
        actionCmd;
        exec(cmd);
    }

    function lock() {
        ensureSwayidleAndRun("loginctl lock-session");
    }

    function logout() {
        exec("my-state clear 're*-required' || true; my-window-close-all || true; sleep 2; sync; loginctl terminate-session $XDG_SESSION_ID");
    }

    function suspend() {
        ensureSwayidleAndRun("my-state clear 're*-required' || true; sync; systemctl suspend");
    }

    function reboot() {
        exec("my-state clear 're*-required' || true; my-window-close-all || true; sleep 3; sync; systemctl reboot");
    }

    function shutdown() {
        exec("my-state clear 're*-required' || true; my-window-close-all || true; sleep 2; sync; systemctl poweroff");
    }
}

