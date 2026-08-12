import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
    id: root

    implicitWidth: 144
    implicitHeight: 32

    RowLayout {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: [
                { icon: "\udb81\udf2c", onClicked: controller.openLauncher },
                { icon: "\uf085", onClicked: controller.openControlCenter },
                { icon: "\uf0f3", onClicked: controller.openNotifManager }
            ]

            delegate: Rectangle {
                required property var modelData

                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                color: "transparent"

                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text: modelData.icon
                    font.family: Theme.iconFont
                    font.pixelSize: btnMouse.containsMouse ? 20 : 16
                    color: btnMouse.containsMouse ? Theme.primary : Qt.alpha(Theme.primary, 0.7)

                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.onClicked()
                }
            }
        }
    }
}
