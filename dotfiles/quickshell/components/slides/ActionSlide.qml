import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
    id: root

    implicitWidth: 156
    implicitHeight: 36

    RowLayout {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: [
                { icon: "\udb81\udf2c", onClicked: controller.openLauncher },
                { icon: "\uf085", onClicked: controller.openControlCenter },
                { icon: "\uf0f3", onClicked: controller.openNotifCenter }
            ]

            delegate: Rectangle {
                required property var modelData

                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                color: "transparent"

                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text: modelData.icon
                    font.family: Theme.iconFont
                    font.pixelSize: hoverHandler.hovered ? 20 : 16
                    color: hoverHandler.hovered ? Theme.primary : Qt.alpha(Theme.primary, 0.7)

                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                HoverHandler {
                    id: hoverHandler
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: modelData.onClicked()
                }
            }
        }
    }
}
