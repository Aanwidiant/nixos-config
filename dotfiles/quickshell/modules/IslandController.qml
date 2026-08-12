import QtQuick
import "../services"

Item {
    id: controller

    property var expandedPopup
    property var osdContainer

    property bool islandVisible: false
    property bool isHovering: false
    property string currentState: "hidden" 
    property bool pendingContent: false
    property string pendingType: "" 
    property bool isClosingExpanded: false
    property var onClosed: null

    readonly property bool isOsdState: currentState === "volume" 
    || currentState === "brightness" 
    || currentState === "microphone"

    readonly property bool isExpandedState: currentState === "polkit" 
    || currentState === "clock_details" 
    || currentState === "music_details" 
    || currentState === "launcher"
    || currentState === "power_system"
    || currentState === "power_profile"
    || currentState === "network"
    || currentState === "bluetooth"
    || currentState === "bluetooth_setting"
    || currentState === "control_center"
    || currentState === "audio_output"
    || currentState === "audio_input"
    || currentState === "clipboard"
    || currentState === "keybind"
    || currentState === "background"
    || currentState === "font"
    || currentState === "theme"
    || currentState === "screenshot"
    || currentState === "screenrecord"
    || currentState === "timer"
    || currentState === "emoji"
    || isOsdState

    readonly property bool isExpandedOrClosing: isExpandedState || isClosingExpanded
    readonly property bool isBusy: isHovering || isExpandedOrClosing || pendingContent

    readonly property var clockShowDelay: timers.clockShowDelay

    IslandTimers {
        id: timers
        controller: controller
    }

    function stopAllTimers() {
        timers.stopAll()
    }

    function startExitSequence() {
        if (isExpandedOrClosing && !isOsdState) return

        if (currentState !== "clock" && currentState !== "hidden") {
            currentState = "clock"
        }

        timers.restartSlideOutDelay()
    }

    function openClockDetails() {
        stopAllTimers()
        currentState = "clock_details"
    }

    function openMusicDetails() {
        stopAllTimers()
        currentState = "music_details"
    }

    function openLauncher() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "launcher"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "launcher"
        }
    }

    function openPowerSystem() {

        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "power_system"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "power_system"
        }
    }

    function openPowerProfile() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "power_profile"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "power_profile"
        }
    }

    function openNetwork() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "network"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "network"
        }
    }

    function openBluetooth() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "bluetooth"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "bluetooth"
        }
    }

    function openBluetoothSettings() {
        stopAllTimers()
        isClosingExpanded = false
        currentState = "bluetooth_setting"
    }

    function openControlCenter() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "control_center"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "control_center"
        }
    }

    function openAudioOutput() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "audio_output"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "audio_output"
        }
    }

    function openAudioInput() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "audio_input"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "audio_input"
        }
    }

    function openClipboard() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "clipboard"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "clipboard"
        }
    }

    function openKeybind() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "keybind"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "keybind"
        }
    }

    function openBackground() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "background"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "background"
        }
    }

    function openFont() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "font"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "font"
        }
    }

    function openTheme() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "theme"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "theme"
        }
    }

    function openScreenshot() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "screenshot"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "screenshot"
        }
    }

    function openScreenrecord() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "screenrecord"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "screenrecord"
        }
    }  

    function openTimer() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "timer"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "timer"
        }
    }

    function openEmoji() {
        stopAllTimers()
        isClosingExpanded = false 

        if (!islandVisible) {
            pendingType = "emoji"
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = "emoji"
        }
    }

    function closeExpandedState(callback = null) {
        if (isExpandedState) {
            onClosed = callback;
            if (osdContainer) osdContainer._showClock = false
            isClosingExpanded = true 
        }
    }

    function triggerContentChange() {
        if (isExpandedOrClosing && !isOsdState) return

        if (!islandVisible) {
            islandVisible = true
            currentState = "clock"
            pendingContent = true
            timers.startExpandToContentTimer()
        } else {
            currentState = pendingType
            timers.stopHideTimer()
            timers.restartResetTimer()
        }
    }

    Connections {
        target: PolkitService

        function onRequestStarted() {
            controller.stopAllTimers()
            controller.isClosingExpanded = false
            if (controller.osdContainer) controller.osdContainer._showClock = false

            if (!controller.islandVisible) {
                controller.pendingType = "polkit"
                controller.currentState = "clock"
                controller.islandVisible = true
                timers.startExpandTimer()
            } else {
                controller.currentState = "polkit"
            }
        }

        function onRequestFinished(success) {
            controller.closeExpandedState()
        }

        function onRequestCancelled() {
            controller.closeExpandedState()
        }
    }

    Connections {
        target: VolumeService

        function onVolumeUpdated() {
            if (controller.isExpandedOrClosing && !controller.isOsdState) return

            controller.pendingType = "volume"
            controller.triggerContentChange()
        }

        function onMuteToggled() {
            if (controller.isExpandedOrClosing && !controller.isOsdState) return
            controller.pendingType = "volume"
            controller.triggerContentChange()
        }
    }

    Connections {
        target: BrightnessService

        function onBrightnessUpdated() {
            if (controller.isExpandedOrClosing && !controller.isOsdState) return
            controller.pendingType = "brightness"
            controller.triggerContentChange()
        }
    }

    Connections {
        target: MicrophoneService

        function onMicrophoneToggled() {
            if (controller.isExpandedOrClosing && !controller.isOsdState) return
            controller.pendingType = "microphone"
            controller.triggerContentChange()
        }
    }

    Connections {
        target: IpcService

        function onRequestOpenLauncher() {
            controller.openLauncher()
        }

        function onRequestPowerSystem() {
            controller.openPowerSystem()
        }

        function onRequestPowerProfile() {
            controller.openPowerProfile()
        } 

        function onRequestControlCenter() {
            controller.openControlCenter()
        }

        function onRequestClipboard() {
            controller.openClipboard()
        }

        function onRequestKeybinds() {
            controller.openKeybind()
        }

        function onRequestEmoji() {
            controller.openEmoji()
        }
    }
}
