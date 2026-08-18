import QtQuick
import Quickshell
import "../theme"
import "../components/expanded"

Item {
    id: popup
    property bool expanded: false
    property string contentType: ""

    readonly property Item activeContent: {
        if (contentType === "polkit") return polkitContent
        if (contentType === "clock_details") return clockExpandedContent
        if (contentType === "music_details") return musicContent
        if (contentType === "launcher") return launcherContent
        if (contentType === "volume") return volumeContent
        if (contentType === "brightness") return brightnessContent
        if (contentType === "microphone") return microphoneContent
        if (contentType === "power_system") return powerSystemContent
        if (contentType === "power_profile") return powerProfileContent
        if (contentType === "network") return networkContent
        if (contentType === "bluetooth") return bluetoothContent
        if (contentType === "bluetooth_setting") return bluetoothSetting
        if (contentType === "control_center") return controlCenter
        if (contentType === "audio_output") return audioOutput
        if (contentType === "audio_input") return audioInput
        if (contentType === "clipboard") return clipboardContent
        if (contentType === "keybind") return keybindContent
        if (contentType === "background") return backgroundContent
        if (contentType === "font") return fontContent
        if (contentType === "theme") return themeContent
        if (contentType === "screenshot") return screenshotContent
        if (contentType === "screenrecord") return screenrecordContent
        if (contentType === "timer") return timerContent
        if (contentType === "emoji") return emojiContent
        if (contentType === "notification") return notifContent
        return null
    }

    implicitWidth: activeContent ? activeContent.implicitWidth : 480
    implicitHeight: activeContent ? activeContent.implicitHeight : 240

    visible: expanded

    Polkit {
        id: polkitContent
        anchors.centerIn: parent 
        visible: popup.contentType === "polkit"
    }

    ClockExpanded {
        id: clockExpandedContent
        anchors.centerIn: parent
        visible: popup.contentType === "clock_details"
    }

    Music {
        id: musicContent
        anchors.centerIn: parent
        visible: popup.contentType === "music_details"
    }

    Launcher {
        id: launcherContent
        anchors.centerIn: parent
        visible: popup.contentType === "launcher"
    }

    PowerSystem {
        id: powerSystemContent
        anchors.centerIn: parent
        visible: popup.contentType === "power_system"
    }

    PowerProfile {
        id: powerProfileContent
        anchors.centerIn: parent
        visible: popup.contentType === "power_profile"
    }

    Volume {
        id: volumeContent
        anchors.centerIn: parent
        visible: popup.contentType === "volume"
    }

    Brightness {
        id: brightnessContent
        anchors.centerIn: parent
        visible: popup.contentType === "brightness"
    }

    Microphone {
        id: microphoneContent
        anchors.centerIn: parent
        visible: popup.contentType === "microphone"
    }

    ControlCenter {
        id: controlCenter
        anchors.centerIn: parent
        visible: popup.contentType === "control_center"
    }

    Network {
        id: networkContent
        anchors.centerIn: parent
        visible: popup.contentType === "network"
    }

    Bluetooth {
        id: bluetoothContent
        anchors.centerIn: parent
        visible: popup.contentType === "bluetooth"
    }

    BluetoothSetting {
        id: bluetoothSetting
        anchors.centerIn: parent
        visible: popup.contentType === "bluetooth_setting"
    }

    AudioOutput {
        id: audioOutput
        anchors.centerIn: parent
        visible: popup.contentType === "audio_output"
    }

    AudioInput {
        id: audioInput
        anchors.centerIn: parent
        visible: popup.contentType === "audio_input"
    }

    Clipboard {
        id: clipboardContent 
        anchors.centerIn: parent
        visible: popup.contentType === "clipboard"
    }

    Keybind {
        id: keybindContent 
        anchors.centerIn: parent
        visible: popup.contentType === "keybind"
    }

    Background {
        id: backgroundContent 
        anchors.centerIn: parent
        visible: popup.contentType === "background"
    }

    Font {
        id: fontContent 
        anchors.centerIn: parent
        visible: popup.contentType === "font"
    }

    Theme {
        id: themeContent 
        anchors.centerIn: parent
        visible: popup.contentType === "theme"
    }

    Screenshot {
        id: screenshotContent 
        anchors.centerIn: parent
        visible: popup.contentType === "screenshot"
    }

    Screenrecord {
        id: screenrecordContent 
        anchors.centerIn: parent
        visible: popup.contentType === "screenrecord"
    }

    TimerTool {
        id: timerContent 
        anchors.centerIn: parent
        visible: popup.contentType === "timer"
    }

    Emoji {
        id: emojiContent 
        anchors.centerIn: parent
        visible: popup.contentType === "emoji"
    }

    Notification {
        id: notifContent
        anchors.centerIn: parent
        visible: popup.contentType === "notification"
    }
}
