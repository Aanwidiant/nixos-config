import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../../theme"
import "../../services"

Item {
    id: root

    property var controller: null
    property int cardBaseHeight: 72
    property int cardMaxHeight: 88
    property int stackOffset: 14

    implicitWidth: 320
    implicitHeight: stackRepeater.count > 0
    ? cardBaseHeight + (Math.min(stackRepeater.count, 3) - 1) * stackOffset
    : 0

    property int focusedIndex: 0
    property int previousCount: 0

    property bool isScrollBusy: false

    Timer {
        id: scrollCooldown
        interval: 150
        onTriggered: root.isScrollBusy = false
    }

    Repeater {
        id: stackRepeater
        model: NotificationService.trackedNotifications

        onCountChanged: {
            if (count > root.previousCount) {
                root.focusedIndex = count - 1
            } else if (root.focusedIndex >= count) {
                root.focusedIndex = count - 1
            }
            root.previousCount = count
        }

        delegate: Rectangle {
            id: card

            required property var modelData
            required property int index

            readonly property int visualIndex: stackRepeater.count > 0
            ? (root.focusedIndex - index + stackRepeater.count) % stackRepeater.count
            : 0

            visible: visualIndex < 3

            width: 320
            height: Math.min(
                Math.max(root.cardBaseHeight, contentRow.implicitHeight + 16),
                root.cardMaxHeight
            )

            anchors.horizontalCenter: parent.horizontalCenter

            y: visualIndex * root.stackOffset
            scale: 1.0 - (visualIndex * 0.05)
            opacity: 1.0 - (visualIndex * 0.2)
            z: 10 - visualIndex

            radius: Metrics.radiusXL
            color: Theme.background

            border.width: 1
            border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.danger : Theme.background

            Behavior on y {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            RowLayout {
                id: contentRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: Metrics.spacingLG

                Image {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: visible ? 0 : -Metrics.spacingLG

                    fillMode: Image.PreserveAspectFit
                    visible: source.toString() !== ""

                    source: card.modelData.image || card.modelData.appIcon || ""
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: card.modelData.summary || ""
                        color: Theme.foreground
                        font.pixelSize: Metrics.textSM
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: card.modelData.body || ""
                        color: Theme.foreground
                        font.pixelSize: Metrics.textXS
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: text !== ""
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onClicked: {
            if (stackRepeater.count > 0) {
                var validIndex = Math.max(0, Math.min(root.focusedIndex, stackRepeater.count - 1))
                var activeItem = stackRepeater.itemAt(validIndex)

                if (activeItem && activeItem.modelData) {
                    NotificationService.dismissNotification(activeItem.modelData)
                }
            }
        }

        onWheel: wheel => {
            wheel.accepted = true
            if (root.isScrollBusy || stackRepeater.count <= 1) return

            root.isScrollBusy = true
            scrollCooldown.restart()

            if (wheel.angleDelta.y < 0) {
                root.focusedIndex = Math.max(0, root.focusedIndex - 1)
            } else if (wheel.angleDelta.y > 0) {
                root.focusedIndex = Math.min(stackRepeater.count - 1, root.focusedIndex + 1)
            }
        }
    }
}
