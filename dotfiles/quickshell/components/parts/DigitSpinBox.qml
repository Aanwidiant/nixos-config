import QtQuick
import QtQuick.Controls.Basic
import "../../services"
import "../../theme"

SpinBox {
    id: control

    from: 0
    to: 9
    stepSize: 1
    editable: true

    implicitWidth: 36
    implicitHeight: 80

    contentItem: TextInput {
        z: 2
        text: control.value
        font.pixelSize: Metrics.text2XL
        font.bold: true
        color: Theme.foreground
        selectionColor: Theme.primary
        selectedTextColor: Theme.surface

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: IntValidator { bottom: 0; top: 9 }
        inputMethodHints: Qt.ImhDigitsOnly

        anchors.top: control.up.indicator.bottom
        anchors.bottom: control.down.indicator.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    up.indicator: Rectangle {
        x: 0
        y: 0
        width: parent.width
        height: 24
        radius: Metrics.radiusXS
        color: control.up.pressed ? Theme.primary : Theme.surface

        Text {
            anchors.centerIn: parent
            text: "\ueb71"
            font.family: Theme.iconFont
            font.pixelSize: Metrics.iconSM
            color: control.up.pressed ? Theme.background : Theme.foreground
        }
    }

    down.indicator: Rectangle {
        x: 0
        y: parent.height - height
        width: parent.width
        height: 24
        radius: Metrics.radiusXS
        color: control.down.pressed ? Theme.primary : Theme.surface

        Text {
            anchors.centerIn: parent
            text: "\ueb6e"
            font.family: Theme.iconFont
            font.pixelSize: Metrics.iconSM
            color: control.down.pressed ? Theme.background : Theme.foreground
        }
    }

    background: Rectangle {
        anchors.fill: parent
        radius: Metrics.radiusSM
        color: "transparent"
        border.color: Theme.border
        border.width: 1
    }
}
