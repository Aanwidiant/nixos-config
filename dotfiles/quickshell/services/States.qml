pragma Singleton
import QtQuick

QtObject {
    id: root

    // ── Semua state popup ──
    readonly property var expandedStates: [
        "polkit", "clock_details", "music_details", "launcher",
        "volume", "brightness", "microphone",
        "power_system", "power_profile", "network", "bluetooth",
        "bluetooth_setting", "control_center", "audio_output", "audio_input",
        "clipboard", "keybind", "background", "font", "theme",
        "screenshot", "screenrecord", "timer", "emoji", "notification"
    ]

    // ── OSD (overlay sementara) ──
    readonly property var osdStates: ["volume", "brightness", "microphone"]

    // ── Dibuka langsung (tanpa pending/expand) ──
    readonly property var directStates: ["clock_details", "music_details", "bluetooth_setting"]

    // ── Butuh keyboard Exclusive ──
    readonly property var exclusiveFocusStates: [
        "polkit", "launcher", "clipboard", "control_center",
        "font", "keybind", "emoji", "background", "theme",
        "power_system", "power_profile"
    ]

    // ── Cukup OnDemand ──
    readonly property var onDemandFocusStates: [
        "clock_details", "music_details", "network", "bluetooth",
        "bluetooth_setting", "audio_output", "audio_input",
        "screenshot", "screenrecord", "timer", "notification"
    ]

    // ── Set untuk lookup cepat ──
    readonly property var expandedSet: new Set(root.expandedStates)
    readonly property var osdSet: new Set(root.osdStates)
    readonly property var directSet: new Set(root.directStates)
    readonly property var exclusiveFocusSet: new Set(root.exclusiveFocusStates)
    readonly property var onDemandFocusSet: new Set(root.onDemandFocusStates)

    // ── State yang bisa dibuka dari hidden via pendingType ──
    readonly property var pendingSet: {
        const s = new Set(root.expandedSet)
        root.osdStates.forEach(x => s.delete(x))
        root.directStates.forEach(x => s.delete(x))
        return s
    }

    function isExpanded(s) { return root.expandedSet.has(s) }
    function isOsd(s) { return root.osdSet.has(s) }
    function isDirect(s) { return root.directSet.has(s) }
    function isPendingType(s) { return root.pendingSet.has(s) }
    function isExclusiveFocus(s) { return root.exclusiveFocusSet.has(s) }
    function isOnDemandFocus(s) { return root.onDemandFocusSet.has(s) }
    function needsKeyboardFocus(s) { return root.exclusiveFocusSet.has(s) || root.onDemandFocusSet.has(s) }
}