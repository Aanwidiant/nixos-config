pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Default true (enabled) karena default disable_trackpad di mango = 0
    property bool isTouchpadActive: true

    Component.onCompleted: initFromConfig()

    // Cuma jalan SEKALI pas shell start, buat nebak state awal dari
    // default value di config file. Ini BUKAN live state dari compositor.
    function initFromConfig() {
        initProcess.running = true
    }

    function toggle() {
        // mango gak nyediain query state real, dan dispatch-nya cuma XOR
        // murni. Satu-satunya sinyal valid: dispatch berhasil terkirim.
        root.isTouchpadActive = !root.isTouchpadActive
        toggleProcess.running = true
    }

    Process {
        id: notifyProcess
        property string message: ""
        command: ["notify-send", "Touchpad", message]
    }

    Process {
        id: initProcess
        command: ["bash", "-c", `
            grep -E '^disable_trackpad=' "$HOME/.config/mango/config.conf" 2>/dev/null | tail -n1 | cut -d= -f2
        `]
        stdout: SplitParser {
            onRead: (data) => {
                const val = data.trim()
                // disable_trackpad=1 berarti nonaktif; baris gak ada/kosong
                // -> fallback ke default mango: aktif
                root.isTouchpadActive = (val !== "1")
            }
        }
    }

    Process {
        id: toggleProcess
        command: ["mmsg", "dispatch", "toggle_trackpad_enable"]
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.isTouchpadActive = !root.isTouchpadActive // rollback
                notifyProcess.message = "Gagal toggle trackpad"
            } else {
                notifyProcess.message = root.isTouchpadActive
                    ? "Touchpad Enabled" : "Touchpad Disabled"
            }
            notifyProcess.running = true
        }
    }
}
