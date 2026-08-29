import QtQuick
import QtQuick.Controls
import "../theme"
import "../components/slides"

Item {
    id: root

    implicitWidth: swipeView.currentItem ? swipeView.currentItem.implicitWidth : 156 
    implicitHeight: swipeView.currentItem ? swipeView.currentItem.implicitHeight : 36

    property int lastIndex: 0
    property bool scrollCooldown: false

    SwipeView {
        id: swipeView
        anchors.fill: parent
        clip: true

        currentIndex: root.lastIndex
        interactive: true

        Component.onCompleted: {
            if (swipeView.contentItem) {
                swipeView.contentItem.highlightMoveDuration = 0

                swipeView.contentItem.movementEnded.connect(function() {
                    if (swipeView.count === 0) return;

                    if (swipeView.currentIndex === swipeView.count - 1 && swipeView.contentItem.contentX > (swipeView.count - 1) * swipeView.width) {
                        swipeView.setCurrentIndex(0)
                    } 
                    else if (swipeView.currentIndex === 0 && swipeView.contentItem.contentX < 0) {
                        swipeView.setCurrentIndex(swipeView.count - 1)
                    }
                })
            }
        }

        onCurrentIndexChanged: {
            if (root.lastIndex !== swipeView.currentIndex) {
                root.lastIndex = swipeView.currentIndex
            }
        }

        ClockSlide {}

        ActionSlide {}

        CavaSlide {}

        // EyeSlide {}

        RecordSlide {}

        TimerSlide {}

        TagsSlide {}
    }

    Timer {
        id: scrollDebounceTimer
        interval: 250 
        repeat: false
        onTriggered: root.scrollCooldown = false
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        blocking: false
        target: null

        onWheel: (event) => {
            if (root.scrollCooldown || swipeView.count === 0) return;

            let delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;
            if (Math.abs(delta) < 20) return;

            if (delta < 0) {
                swipeView.currentIndex = (swipeView.currentIndex + 1) % swipeView.count;
            } else {
                swipeView.currentIndex = (swipeView.currentIndex - 1 + swipeView.count) % swipeView.count;
            }

            root.scrollCooldown = true;
            scrollDebounceTimer.restart();
        }
    }
}
