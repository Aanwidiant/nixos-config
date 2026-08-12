import QtQuick
import QtQuick.Controls
import "../theme"
import "../components/slides"

Item {
    id: root

    implicitWidth: swipeView.currentItem ? swipeView.currentItem.implicitWidth : 144
    implicitHeight: swipeView.currentItem ? swipeView.currentItem.implicitHeight : 32

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

        EyeSlide {}

        RecordSlide {}

        TimerSlide {}
    }

    Timer {
        id: scrollDebounceTimer
        interval: 250 
        repeat: false
        onTriggered: root.scrollCooldown = false
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor 
        acceptedButtons: Qt.NoButton 

        onWheel: wheel => {
            if (root.scrollCooldown) return;

            let delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;
            if (Math.abs(delta) < 20) return; 

            if (delta < 0) {
                if (swipeView.currentIndex < swipeView.count - 1) {
                    swipeView.currentIndex++
                    root.scrollCooldown = true
                    scrollDebounceTimer.restart()
                }
            } else {
                if (swipeView.currentIndex > 0) {
                    swipeView.currentIndex--
                    root.scrollCooldown = true
                    scrollDebounceTimer.restart()
                }
            }
        }
    }

}
