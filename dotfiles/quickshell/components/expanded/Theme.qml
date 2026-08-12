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

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: controller.closeExpandedState()
    }

    onVisibleChanged: {
        if (visible) {
            ThemeService.refresh();
            themeGrid.forceActiveFocus();
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
                iconText: "\udb80\udfd8"
            }

            Text {
                text: "Theme"
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
            id: themeGrid
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            focus: true

            keyNavigationWraps: false

            cellWidth: width / 2
            cellHeight: 130 

            model: ThemeService.themesList || []

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    if (currentIndex >= 0 && currentIndex < model.length) {
                        ThemeService.selectTheme(model[currentIndex], controller.closeExpandedState);
                        event.accepted = true;
                    }
                }
            }

            delegate: Item {
                id: delegateItem
                required property var modelData
                required property int index

                width: themeGrid.cellWidth
                height: themeGrid.cellHeight

                Rectangle {
                    id: card
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: Metrics.radiusMD
                    color: Theme.surface

                    border.color: themeGrid.currentIndex === delegateItem.index ? Theme.primary : "transparent"
                    border.width: 2

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: Metrics.radiusMD - 2
                        color: "transparent"

                        Image {
                            id: previewImage
                            anchors.fill: parent
                            source: "file://" + delegateItem.modelData + "/preview.png"
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: Qt.rgba(0, 0, 0, 0.35)
                        }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 24

                            text: {
                                const path = delegateItem.modelData || "";
                                const name = path.split("/").pop();

                                return name
                                .replace(/[_-]+/g, " ")
                                .replace(/\b\w/g, c => c.toUpperCase());
                            }

                            color: Theme.foreground
                            font.pixelSize: Metrics.textMD
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            if (themeGrid.currentIndex !== delegateItem.index) {
                                themeGrid.currentIndex = delegateItem.index;
                            } else {
                                ThemeService.selectTheme(delegateItem.modelData, controller.closeExpandedState);
                            }
                        }
                    }
                }
            }
        }
    }
}
