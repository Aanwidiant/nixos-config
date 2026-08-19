import QtQuick
import "../components/expanded"

Item {
    id: popup
    property bool expanded: false
    property string contentType: ""

    readonly property Item activeContent: contentLoader.item

    implicitWidth: activeContent ? activeContent.implicitWidth : 480
    implicitHeight: activeContent ? activeContent.implicitHeight : 240

    visible: expanded

    readonly property Component contentComponent: {
        switch (contentType) {
        case "polkit": return polkitComp
        case "clock_details": return clockExpandedComp
        case "music_details": return musicComp
        case "launcher": return launcherComp
        case "volume": return volumeComp
        case "brightness": return brightnessComp
        case "microphone": return microphoneComp
        case "power_system": return powerSystemComp
        case "power_profile": return powerProfileComp
        case "network": return networkComp
        case "bluetooth": return bluetoothComp
        case "bluetooth_setting": return bluetoothSettingComp
        case "control_center": return controlCenterComp
        case "audio_output": return audioOutputComp
        case "audio_input": return audioInputComp
        case "clipboard": return clipboardComp
        case "keybind": return keybindComp
        case "background": return backgroundComp
        case "font": return fontComp
        case "theme": return themeComp
        case "screenshot": return screenshotComp
        case "screenrecord": return screenrecordComp
        case "timer": return timerComp
        case "emoji": return emojiComp
        case "notification": return notifComp
        default: return null
        }
    }

    Loader {
        id: contentLoader
        anchors.centerIn: parent
        sourceComponent: popup.contentComponent
        active: popup.expanded

        onLoaded: {
            const item = contentLoader.item
            if (item) {
                item.visible = false
                item.visible = true
            }
        }
    }

    Component { id: polkitComp; Polkit {} }
    Component { id: clockExpandedComp; ClockExpanded {} }
    Component { id: musicComp; Music {} }
    Component { id: launcherComp; Launcher {} }
    Component { id: volumeComp; Volume {} }
    Component { id: brightnessComp; Brightness {} }
    Component { id: microphoneComp; Microphone {} }
    Component { id: powerSystemComp; PowerSystem {} }
    Component { id: powerProfileComp; PowerProfile {} }
    Component { id: networkComp; Network {} }
    Component { id: bluetoothComp; Bluetooth {} }
    Component { id: bluetoothSettingComp; BluetoothSetting {} }
    Component { id: controlCenterComp; ControlCenter {} }
    Component { id: audioOutputComp; AudioOutput {} }
    Component { id: audioInputComp; AudioInput {} }
    Component { id: clipboardComp; Clipboard {} }
    Component { id: keybindComp; Keybind {} }
    Component { id: backgroundComp; Background {} }
    Component { id: fontComp; Font {} }
    Component { id: themeComp; Theme {} }
    Component { id: screenshotComp; Screenshot {} }
    Component { id: screenrecordComp; Screenrecord {} }
    Component { id: timerComp; TimerTool {} }
    Component { id: emojiComp; Emoji {} }
    Component { id: notifComp; Notification {} }
}
