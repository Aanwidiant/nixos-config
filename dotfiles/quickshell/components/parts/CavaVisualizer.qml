import QtQuick
import "../../theme"
import "../../services"

Item {
    id: root

    property bool running: true
    property bool isVisible: true
    property int barCount: 6
    property int barWidth: 3
    property int barSpacing: 3
    property int minHeight: 2
    property int maxHeight: 14
    property color barColor: Theme.foreground

    Connections {
        target: CavaService

        function onSpectrumUpdated() {
            if (root.isVisible && root.running) {
                updateBars()
            }
        }
    }

    width: barCount * barWidth + (barCount - 1) * barSpacing
    height: maxHeight

    property int actualBarCount: CavaService.barCount || barCount

    function updateBars() {
        if (!root.isVisible || !root.running) return

        var count = Math.min(CavaService.spectrum.length, root.barCount)
        for (var i = 0; i < count; i++) {
            var value = CavaService.getBarHeight(i) || 0
            var targetHeight = root.minHeight + (root.maxHeight - root.minHeight) * Math.min(1, value)

            var bar = barRepeater.itemAt(i)
            if (bar) {
                bar.targetHeight = targetHeight
                bar.height = targetHeight
            }
        }
    }

    function syncActiveState() {
        var shouldBeActive = root.isVisible && root.running

        if (shouldBeActive) {
            CavaService.setActive(true)
            updateBars() 
        } else {
            CavaService.setActive(false)
        }
    }

    onIsVisibleChanged: syncActiveState()
    onRunningChanged: syncActiveState()

    Repeater {
        id: barRepeater
        model: Math.min(actualBarCount, root.barCount)

        Rectangle {
            id: barItem
            required property int index

            property real targetHeight: root.minHeight

            width: root.barWidth
            height: root.minHeight
            radius: width / 2
            color: root.barColor
            opacity: 0.5 + (height / root.maxHeight) * 0.5

            x: index * (root.barWidth + root.barSpacing)
            anchors.bottom: parent.bottom

            Behavior on height {
                NumberAnimation {
                    duration: barItem.targetHeight > barItem.height ? 25 : 80
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Component.onCompleted: {
        syncActiveState()
    }

    Component.onDestruction: {
        CavaService.setActive(false)
    }
}
