import QtQuick
import "../services"

Item {
    id: timersRoot

    required property var controller

    function stopAll() {
        expandTimer.stop()
        expandToContentTimer.stop()
        resetTimer.stop()
        hideTimer.stop()
        slideOutDelayTimer.stop()
        slideOutTimer.stop()
        clockShowDelay.stop()
    }

    function startExpandTimer() { expandTimer.start() }
    function startExpandToContentTimer() { expandToContentTimer.start() }
    function restartResetTimer() { resetTimer.restart() }
    function stopHideTimer() { hideTimer.stop() }
    function restartSlideOutDelay() { slideOutDelayTimer.restart() }
    function startClockShowDelay() { clockShowDelay.start() }

    Timer {
        id: expandTimer
        interval: 250
        onTriggered: {
            if (States.isPendingType(controller.pendingType)) {
                controller.currentState = controller.pendingType
                controller.pendingType = ""
            }
        }
    }

    Timer {
        id: expandToContentTimer
        interval: 120
        onTriggered: {
            if (controller.isExpandedOrClosing && !controller.isOsdState) return
            controller.currentState = controller.pendingType
            controller.pendingContent = false
            hideTimer.stop()
            resetTimer.restart()
        }
    }

    Timer {
        id: resetTimer
        interval: 1500
        onTriggered: {
            if (controller.isOsdState) {
                controller.currentState = "clock"
                if (!controller.isHovering) {
                    slideOutDelayTimer.restart()
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: {
            if (!controller.isBusy) {
                if (controller.currentState !== "clock") {
                    controller.currentState = "clock"
                }
                slideOutDelayTimer.restart()
            }
        }
    }

    Timer {
        id: slideOutDelayTimer
        interval: 300
        onTriggered: {
            if (!controller.isBusy) {
                slideOutTimer.restart()
            }
        }
    }

    Timer {
        id: slideOutTimer
        interval: 120
        onTriggered: {
            if (!controller.isBusy) {
                controller.islandVisible = false
                controller.currentState = "hidden"

                if (controller.onClosed) {
                    const cb = controller.onClosed;
                    controller.onClosed = null;
                    cb();
                }
            }
        }
    }

    Timer {
        id: clockShowDelay
        interval: 120
        onTriggered: {
            if (controller.isClosingExpanded && controller.osdContainer) {
                controller.osdContainer._showClock = true
            }
        }
    }
}
