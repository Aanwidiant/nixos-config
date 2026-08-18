import QtQuick
import Quickshell.Widgets
import QtQuick.Layouts
import "../../services"
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: 400

    CloseButton {}

    onVisibleChanged: {
        if (visible) {
            BackgroundService.refresh();
            backgroundGrid.forceActiveFocus();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacingLG

            HeaderIcon {
                iconText: "\uf03e"
            }

            Text {
                text: "Background"
                font.pixelSize: Metrics.textLG
                font.bold: true
                color: Theme.foreground
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        GridView {
            id: backgroundGrid
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            focus: true

            keyNavigationWraps: false

            cellWidth: width / 2
            cellHeight: 130 

            model: BackgroundService.backgroundsList || []

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    if (currentIndex >= 0 && currentIndex < model.length) {
                        BackgroundService.selectBackground(model[currentIndex], controller.closeExpandedState);
                        event.accepted = true;
                    }
                }
            }

            delegate: Item {
                id: delegateItem
                required property var modelData
                required property int index

                width: backgroundGrid.cellWidth
                height: backgroundGrid.cellHeight

                Rectangle {
                    id: card
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: Metrics.radiusMD
                    color: Theme.surface

                    border.color: backgroundGrid.currentIndex === delegateItem.index ? Theme.primary : "transparent"
                    border.width: 2

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: Metrics.radiusMD - 2
                        color: "transparent"

                        Image {
                            anchors.fill: parent
                            source: "file://" + delegateItem.modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            if (backgroundGrid.currentIndex !== delegateItem.index) {
                                backgroundGrid.currentIndex = delegateItem.index;
                            } else {
                                BackgroundService.selectBackground(delegateItem.modelData, controller.closeExpandedState);
                            }
                        }
                    }
                }
            }
        }
    }
}
