import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../../services"
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: 400

    CloseButton {}

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            HeaderIcon {
                iconText: "\uf0f3"
            }

            Text {
                text: "Notification Center"
                font.pixelSize: Metrics.textLG
                font.bold: true
                font.family: Theme.textFont
                color: Theme.foreground
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "Clear All"
                font.pixelSize: Metrics.textSM
                font.weight: Font.Medium
                font.family: Theme.textFont
                color: clearHover.hovered ? Theme.primary : Qt.alpha(Theme.primary, 0.9)
                Layout.alignment: Qt.AlignVCenter
                visible: NotificationService.historyCount > 0

                HoverHandler {
                    id: clearHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: NotificationService.removeAllHistory()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: NotificationService.historyCount === 0

            Column {
                anchors.centerIn: parent
                spacing: Metrics.spacingLG

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\uf0f3"
                    font.family: Theme.iconFont
                    font.pixelSize: Metrics.text5XL
                    color: Theme.muted
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No notifications"
                    color: Theme.muted
                    font.pixelSize: Metrics.textMD
                    font.family: Theme.textFont
                }
            }
        }

        Flickable {
            id: flick
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: NotificationService.historyCount > 0
            clip: true
            contentWidth: width
            contentHeight: listColumn.height >= 0 ? listColumn.height : 0
            // ScrollIndicator.vertical: ScrollIndicator {
            //     visible: flick.contentHeight > flick.height
            //     contentItem: Rectangle {
            //         implicitWidth: 4
            //         radius: 2
            //         color: Qt.alpha(Theme.primary, 0.5)
            //     }
            // }

            Column {
                id: listColumn
                width: parent.width
                spacing: Metrics.spacingMD

                Repeater {
                    model: NotificationService.history

                    delegate: Rectangle {
                        id: card

                        required property int index
                        required property var modelData

                        width: listColumn.width
                        height: contentCol.implicitHeight + 28

                        radius: Metrics.radiusMD
                        color: Theme.background

                        border.width: 1
                        border.color: (card.modelData.urgency === NotificationUrgency.Critical)
                        ? Theme.danger
                        : Theme.primary

                        ColumnLayout {
                            id: contentCol
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 12
                            anchors.leftMargin: 16
                            anchors.rightMargin: 48
                            spacing: Metrics.spacingLG

                            RowLayout {
                                spacing: Metrics.spacingMD

                                Image {
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.rightMargin: visible ? 0 : -Metrics.spacingMD
                                    fillMode: Image.PreserveAspectFit
                                    visible: source.toString() !== ""
                                    source: card.modelData.image || card.modelData.appIcon || ""
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: Metrics.spacingSM

                                    Text {
                                        Layout.fillWidth: true
                                        text: card.modelData.appName || ""
                                        color: Theme.muted
                                        font.pixelSize: Metrics.textXS
                                        font.family: Theme.textFont
                                        elide: Text.ElideRight
                                        visible: text !== ""
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: card.modelData.summary || ""
                                        color: Theme.foreground
                                        font.pixelSize: Metrics.textSM
                                        font.family: Theme.textFont
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.body || ""
                                color: Theme.foreground
                                font.pixelSize: Metrics.textXS
                                font.family: Theme.textFont
                                wrapMode: Text.Wrap
                                visible: text !== ""
                            }
                        }

                        Text {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 10
                            anchors.rightMargin: 12
                            text: "\uf00d"
                            font.family: Theme.iconFont
                            font.pixelSize: Metrics.iconSM
                            color: removeHover.hovered ? Theme.primary : Qt.alpha(Theme.primary, 0.9)

                            HoverHandler {
                                id: removeHover
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                onTapped: NotificationService.removeHistory(index)
                            }
                        }

                        Text {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.bottomMargin: 8
                            anchors.rightMargin: 12
                            text: card.modelData.time || ""
                            color: Theme.muted
                            font.pixelSize: Metrics.textXS
                            font.family: Theme.textFont
                            visible: text !== ""
                        }
                    }
                } 
            }
        }
    }
}
