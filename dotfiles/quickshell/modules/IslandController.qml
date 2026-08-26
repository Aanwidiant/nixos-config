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
    property bool stayVisible: IpcService.stayVisible

    readonly property bool isOsdState: States.isOsd(currentState)
    readonly property bool isExpandedState: States.isExpanded(currentState)

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

    function openExpanded(type) {
        stopAllTimers()
        isClosingExpanded = false
        if (!islandVisible) {
            pendingType = type
            currentState = "clock"
            islandVisible = true
            timers.startExpandTimer()
        } else {
            currentState = type
        }
    }

    function startExitSequence() {
        if (isExpandedOrClosing && !isOsdState) return

        if (currentState !== "clock" && currentState !== "hidden") {
            currentState = "clock"
        }

        if (stayVisible) return
        timers.restartSlideOutDelay()
    }

    onStayVisibleChanged: {
        if (stayVisible) {
            stopAllTimers()
            if (!islandVisible || currentState === "hidden") {
                currentState = "clock"
                islandVisible = true
            }
        } else if (!isBusy) {
            startExitSequence()
        }
    }

    function openClockDetails() {
        stopAllTimers()
        currentState = "clock_details"
    }

    function openMusicDetails() {
        stopAllTimers()
        currentState = "music_details"
    }

    function openLauncher() { openExpanded("launcher") }

    function openPowerSystem() { openExpanded("power_system") }

    function openPowerProfile() { openExpanded("power_profile") }

    function openNetwork() { openExpanded("network") }

    function openBluetooth() { openExpanded("bluetooth") }

    function openBluetoothSettings() {
        stopAllTimers()
        isClosingExpanded = false
        currentState = "bluetooth_setting"
    }

    function openControlCenter() { openExpanded("control_center") }

    function openAudioOutput() { openExpanded("audio_output") }

    function openAudioInput() { openExpanded("audio_input") }

    function openClipboard() { openExpanded("clipboard") }

    function openKeybind() { openExpanded("keybind") }

    function openBackground() { openExpanded("background") }

    function openFont() { openExpanded("font") }

    function openTheme() { openExpanded("theme") }

    function openScreenshot() { openExpanded("screenshot") }

    function openScreenrecord() { openExpanded("screenrecord") }

    function openTimer() { openExpanded("timer") }

    function openEmoji() { openExpanded("emoji") }

    function openNotifCenter() { openExpanded("notif-center") }

    function closeExpandedState(callback = null) {
        if (isExpandedState) {
            onClosed = callback;
            if (osdContainer) osdContainer._showClock = false
            isClosingExpanded = true

            var delayTimer = Qt.createQmlObject('import QtQuick; Timer { interval: 150; repeat: false; }', controller)
            delayTimer.triggered.connect(function() {
                isClosingExpanded = false
                currentState = "clock"

                if (onClosed && typeof onClosed === "function") {
                    onClosed()
                    onClosed = null
                }

                if (!isHovering && !stayVisible) {
                    startExitSequence()
                }

                delayTimer.destroy() 
            })
            delayTimer.start()
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
        target: NotificationService

        function onNotificationReceived(notification) {
            if (controller.currentState === "polkit") return

            if (controller.currentState === "notif-popup") {
                timers.restartResetTimer()
                return
            }

            controller.isClosingExpanded = false
            controller.pendingType = "notif-popup"

            if (!controller.islandVisible) {
                controller.islandVisible = true
                controller.currentState = "clock"
                controller.pendingContent = true
                timers.startExpandToContentTimer()
            } else {
                controller.currentState = "notif-popup"
                timers.stopHideTimer()
                timers.restartResetTimer()
            }
        }

        function onNotificationDismissed(notification) {
            if (NotificationService.activeCount === 0) {
                controller.closeExpandedState()
            }
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
