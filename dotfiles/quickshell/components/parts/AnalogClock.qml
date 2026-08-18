import Quickshell
import QtQuick
import "../../theme"

Item {
    id: clockRoot

    implicitWidth: 120
    implicitHeight: 120

    property string timeFormat: "hh:mm"
    property int precision: SystemClock.Minutes

    SystemClock {
        id: clock
        precision: clockRoot.precision
    }

    Rectangle {
        id: clockFace
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: Theme.border
        border.width: 1.5

        Repeater {
            model: 12

            Item {
                id: dotContainer
                required property int index

                anchors.fill: parent
                rotation: dotContainer.index * 30

                Rectangle {
                    id: hourDot
                    property bool isMajor: dotContainer.index % 3 === 0

                    width: isMajor ? 3 : 2
                    height: width * 2

                    color: isMajor ? Theme.primary : Theme.muted

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 2
                }
            }
        }

        Rectangle {
            id: hourHand
            width: Math.max(2, parent.width * 0.05)
            height: parent.height * 0.25
            color: Theme.primary
            radius: 2
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height

            transform: Rotation {
                origin.x: hourHand.width / 2
                origin.y: hourHand.height
                angle: {
                    var h = clock.date.getHours() % 12
                    var m = clock.date.getMinutes()
                    return (h + m / 60) * 30
                }
            }
        }

        Rectangle {
            id: minuteHand
            width: Math.max(1.5, parent.width * 0.03)
            height: parent.height * 0.36
            color: Theme.foreground
            radius: 1
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height

            transform: Rotation {
                origin.x: minuteHand.width / 2
                origin.y: minuteHand.height
                angle: clock.date.getMinutes() * 6
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.max(4, parent.width * 0.08)
            height: width
            radius: width / 2
            color: Theme.primary
        }
    }
}
