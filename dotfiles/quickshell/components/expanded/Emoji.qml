import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../services"
import "../../theme"

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
        if (!visible) {
            searchInput.clear();
        } else {
            searchInput.forceActiveFocus();
            grid.currentIndex = 0;
        }
    }

    ScriptModel {
        id: filteredModel

        values: {
            const all = EmojiService.emojiList || [];
            const q = searchInput.text.trim().toLowerCase();

            if (q === "") return all;

            return all.filter(item => item.name.toLowerCase().includes(q));
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: Metrics.spacingLG

        // 1. Search Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            color: Theme.surface
            radius: Metrics.radiusMD

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: ""
                    font.family: Theme.iconFont
                    color: Theme.primary
                    font.pixelSize: Metrics.textXL
                    font.weight: Font.ExtraBold
                    verticalAlignment: Text.AlignVCenter
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Search emoji..."
                    placeholderTextColor: Theme.muted
                    color: Theme.foreground
                    font.pixelSize: Metrics.textMD
                    padding: 0
                    background: Rectangle { color: "transparent" }

                    Keys.onPressed: (event) => {
                        const columns = Math.floor(grid.width / grid.cellWidth);

                        if (event.key === Qt.Key_Left) {
                            event.accepted = true;
                            if (grid.currentIndex > 0) grid.currentIndex--;
                        } else if (event.key === Qt.Key_Right) {
                            event.accepted = true;
                            if (grid.currentIndex < grid.count - 1) grid.currentIndex++;
                        } else if (event.key === Qt.Key_Up) {
                            event.accepted = true;
                            if (grid.currentIndex - columns >= 0) grid.currentIndex -= columns;
                        } else if (event.key === Qt.Key_Down) {
                            event.accepted = true;
                            if (grid.currentIndex + columns < grid.count) grid.currentIndex += columns;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = true;
                            if (grid.currentItem) {
                                // SALIN KE CLIPBOARD DAN TUTUP VIEW
                                EmojiService.copyEmoji(
                                    grid.currentItem.modelData.emoji, 
                                    controller.closeExpandedState
                                );
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: Metrics.radiusFull
                    visible: searchInput.text !== ""
                    color: clearMouse.containsMouse ? Theme.accent : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: Theme.iconFont
                        color: clearMouse.containsMouse ? Theme.background : Theme.accent
                        font.pixelSize: Metrics.textMD
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchInput.clear();
                            searchInput.forceActiveFocus();
                        }
                    }
                }
            }
        }

        // 2. Emoji Grid View
        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            cellWidth: 48
            cellHeight: 48

            readonly property int columns: Math.floor(width / cellWidth)
            leftMargin: Math.floor((width - (columns * cellWidth)) / 2)
            rightMargin: leftMargin

            model: filteredModel.values

            delegate: Rectangle {
                id: emojiCell
                required property var modelData
                required property int index

                readonly property bool isCurrent: GridView.isCurrentItem
                readonly property bool isHovered: cellHover.hovered

                width: grid.cellWidth - 6
                height: grid.cellHeight - 6
                radius: Metrics.radiusSM

                color: isCurrent 
                ? Qt.alpha(Theme.primary, 0.75) 
                : (isHovered ? Qt.alpha(Theme.surface, 0.6) : "transparent")

                Behavior on color { ColorAnimation { duration: 120 } }

                HoverHandler {
                    id: cellHover
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    anchors.centerIn: parent
                    text: emojiCell.modelData.emoji
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        if (grid.currentIndex === emojiCell.index) {
                            // Klik Kedua -> Salin ke clipboard & tutup view
                            EmojiService.copyEmoji(
                                emojiCell.modelData.emoji, 
                                controller.closeExpandedState
                            );
                        } else {
                            // Klik Pertama -> Pilih item
                            grid.currentIndex = emojiCell.index;
                        }
                    }
                }
            }
        }
    }
}
