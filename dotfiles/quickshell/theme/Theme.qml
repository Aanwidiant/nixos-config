pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    // exposed supaya bisa dipanggil Theme.themeFile.reload() dari luar
    readonly property FileView themeFile: FileView {
        id: themeFile
        path: Quickshell.env("HOME") + "/.config/theme/current/theme/qs.json"
        onTextChanged: root.loadTheme()
    }

    function loadTheme() {
        const raw = themeFile.text();
        if (!raw) return;
        const trimmed = raw.trim();
        if (!trimmed) return;
        try {
            let data = JSON.parse(trimmed);
            root.background = Qt.color(data.background || "#1b1e28");
            root.surface    = Qt.color(data.surface    || "#2e3440");
            root.foreground = Qt.color(data.foreground || "#eceff4");
            root.muted      = Qt.color(data.muted      || "#4c566a");
            root.border     = Qt.color(data.border     || "#3b4252");
            root.primary    = Qt.color(data.primary    || "#88c0d0");
            root.secondary  = Qt.color(data.secondary  || "#81a1c1");
            root.accent     = Qt.color(data.accent     || "#8fbcbb");
            root.success    = Qt.color(data.success    || "#a3be8c");
            root.warning    = Qt.color(data.warning    || "#ebcb8b");
            root.danger     = Qt.color(data.danger     || "#bf616a");
            root.iconFont   = data.iconFont            || "JetBrainsMono Nerd Font";
        } catch (e) {
            // abaikan partial read
        }
    }

    Component.onCompleted: root.loadTheme()

    property color background: "#1b1e28"
    property color surface:    "#2e3440"
    property color foreground: "#eceff4"
    property color muted:      "#4c566a"
    property color border:     "#3b4252"
    property color primary:    "#88c0d0"
    property color secondary:  "#81a1c1"
    property color accent:     "#8fbcbb"
    property color success:    "#a3be8c"
    property color warning:    "#ebcb8b"
    property color danger:     "#bf616a"
    property string iconFont:  "JetBrainsMono Nerd Font"
}
