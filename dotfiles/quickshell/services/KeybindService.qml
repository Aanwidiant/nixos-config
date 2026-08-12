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

// KeybindsService.qml

// Mengekstrak tombol/shortcut (sebelum spasi ganda / TAB)
function getKey(rawItem) {
    if (!rawItem) return "";
    let parts = rawItem.trim().split(/\t|\s{2,}/);
    return parts.length > 1 ? parts[0].trim() : "";
}

// Mengekstrak deskripsi (setelah spasi ganda / TAB)
function getDescription(rawItem) {
    if (!rawItem) return "";
    let parts = rawItem.trim().split(/\t|\s{2,}/);
    return parts.length > 1 ? parts.slice(1).join(" ").trim() : rawItem.trim();
}

    // Aksi saat item dipilih
    function selectItem(rawItem, closeCallback) {
        if (!rawItem) return;
        // Jalankan logika/copy keybind jika diperlukan
        if (typeof closeCallback === "function") {
            closeCallback();
        }
    }

    Process {
        id: fetchProcess
        // Membaca bindings.txt, mengabaikan komentar (#) dan baris kosong
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
