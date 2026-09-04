import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services"
import "../../theme"

Item {
    id: root

    implicitWidth: 156
    implicitHeight: 36

    readonly property bool active: RecordService.isRecording
    readonly property string displayTime: active ? RecordService.formattedTime : "00:00"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: Metrics.spacingLG

        RowLayout {
            spacing: Metrics.spacingLG 
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: "\udb81\udc4b"
                font.pixelSize: Metrics.iconSM
                font.family: Theme.iconFont
                color: root.active ? Theme.danger : Theme.foreground

                SequentialAnimation on opacity {
                    running: RecordService.isRecording && SwipeView.isCurrentItem
                    loops: Animation.Infinite

                    NumberAnimation { to: 0.3; duration: 800 }
                    NumberAnimation { to: 1.0; duration: 800 }
                }
            }

            Text {
                text: root.displayTime
                color: Theme.foreground
                font.pixelSize: Metrics.textSM 
                font.bold: true
                font.family: Theme.textFont
            }
        }

        Item {
            implicitWidth: 12
            implicitHeight: 12
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: root.active ? "\uf28e" : "\uf03d" 
                font.pixelSize: Metrics.iconSM
                font.family: Theme.iconFont
                color: root.active ? Theme.danger : Theme.foreground
            }

            HoverHandler {
                cursorShape: root.active ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            TapHandler {
                gesturePolicy: TapHandler.WithinBounds

                onTapped: (eventPoint) => {
                    if (root.active) {
                        RecordService.stopRecording();
                        eventPoint.accepted = true; 
                    }
                }
            }
        }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    TapHandler {
        onTapped: controller.openScreenrecord()
    }
}
