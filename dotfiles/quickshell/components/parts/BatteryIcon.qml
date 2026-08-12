import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../services"

Item {
    id: root

    implicitWidth: bodyRectangle.width + tipRectangle.width + tipSpacing
    implicitHeight: 18

    property color colorNormal: Theme.primary 
    property color colorWarning: Theme.warning
    property color colorDanger: Theme.danger
    property color colorCharging: Theme.primary
    property color borderColor: Theme.foreground

    readonly property int pct: BatteryService.percentage
    readonly property bool charging: BatteryService.isCharging || BatteryService.isPluggedIn

    readonly property color currentBatteryColor: {
        if (charging) return colorCharging
        if (pct <= 10) return colorDanger
        if (pct <= 20) return colorWarning
        return colorNormal
    }

    readonly property real tipSpacing: 1

    Rectangle {
        id: bodyRectangle
        width: 36
        height: parent.height
        radius: Metrics.radiusXS
        color: "transparent"
        border.color: root.borderColor
        border.width: 1.5

        Rectangle {
            id: batteryFill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2 
            radius: Metrics.radius2XS

            readonly property real maxFillWidth: bodyRectangle.width - (anchors.margins * 2)
            width: Math.max(0, Math.min(maxFillWidth, (root.pct / 100) * maxFillWidth))

            color: root.currentBatteryColor

            Behavior on width {
                SmoothedAnimation { velocity: 150 }
            }
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 2

            Text {
                visible: root.charging
                text: "\udb85\udc0b"
                font.family: Theme.iconFont
                font.pixelSize: Metrics.textXS
                color: Theme.foreground

                Behavior on visible {
                    NumberAnimation { duration: 150 }
                }
            }

            Text {
                text: root.pct
                font.pixelSize: Metrics.textXS
                color: Theme.foreground 
            }
        }
    }

    Rectangle {
        id: tipRectangle
        anchors.left: bodyRectangle.right
        anchors.leftMargin: root.tipSpacing
        anchors.verticalCenter: bodyRectangle.verticalCenter
        width: 1
        height: bodyRectangle.height * 0.45
        radius: Metrics.radiusFull
        color: root.borderColor
    }
}
