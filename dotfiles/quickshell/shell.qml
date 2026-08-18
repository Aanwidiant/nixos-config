import Quickshell
import Quickshell.Wayland
import QtQuick
import "modules"
import "services"

ShellRoot {
    id: root

    PanelWindow {
        id: mainPanel

        readonly property var targetScreen: {
            var targetName = ScreenService.activeMonitorName
            if (!targetName) return Quickshell.screens[0]
            return Quickshell.screens.find(s => s.name === targetName) ?? Quickshell.screens[0]
        }

        property var lockedScreen: null

        screen: {
            if (!requiresKeyboardFocus || lockedScreen === null) {
                return targetScreen
            }
            return lockedScreen
        }

        onScreenChanged: {
            if (screen) {
                lockedScreen = screen
            }
        }  

        anchors.top: true
        exclusiveZone: 0 
        color: "transparent"

        implicitWidth: mainPanel.screen ? mainPanel.screen.width * 1/2 : 0
        implicitHeight: mainPanel.screen ? mainPanel.screen.height * 4/5 : 0

        readonly property bool requiresKeyboardFocus: [
            "clock_details",
            "music_details",
            "polkit",
            "launcher",
            "power_system",
            "power_profile",
            "network",
            "bluetooth",
            "bluetooth_setting",
            "control_center",
            "audio_output",
            "audio_input",
            "clipboard",
            "keybind",
            "background",
            "font",
            "theme",
            "screenshot",
            "screenrecord",
            "timer",
            "emoji"
        ].includes(dynamicIsland.currentState)

        WlrLayershell.keyboardFocus:
        dynamicIsland.currentState === "notification"
        ? WlrKeyboardFocus.OnDemand
        : requiresKeyboardFocus
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

        WlrLayershell.layer: WlrLayer.Top

        DynamicIsland {
            id: dynamicIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
        }

        mask: Region {
            item: dynamicIsland.islandVisible ? dynamicIsland.islandItem : dynamicIsland.topEdgeTrigger
        }
    }

    Component.onCompleted: {
        const _ipc = IpcService 
    }
}
