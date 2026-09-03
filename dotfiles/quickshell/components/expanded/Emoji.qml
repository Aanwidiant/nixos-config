import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../services"
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: 400

    CloseButton {}

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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            color: Theme.surface
            radius: Metrics.radiusMD

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                spacing: Metrics.spacingLG

                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    color: "transparent"

                    Text {
                        anchors.fill: parent 
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: Theme.iconFont
                        text: "" 
                        color: Theme.primary
                        font.pixelSize: Metrics.textXL
                        font.weight: Font.ExtraBold
                    }
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
                                EmojiService.copyEmoji(
                                    grid.currentItem.modelData.emoji, 
                                    controller.closeExpandedState
                                );
                            }
                        }
                    }
                }

                Rectangle {
                    id: clearBtn
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: Metrics.radiusFull
                    visible: searchInput.text !== ""
                    color: clearHover.hovered ? Theme.accent : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.fill: parent 
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: ""                             
                        font.family: Theme.iconFont
                        color: clearHover.hovered ? Theme.background : Theme.accent
                        font.pixelSize: Metrics.textXL
                        font.weight: Font.ExtraBold
                    }

                    HoverHandler {
                        id: clearHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            searchInput.clear();
                            searchInput.forceActiveFocus();
                        }
                    }
                }
            }
        }

        GridView {
            id: grid

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            cellWidth: 40
            cellHeight: 40

            readonly property int columns: Math.max(
                1,
                Math.floor(width / cellWidth)
            )

            leftMargin: Math.max(
                0,
                (width - columns * cellWidth) / 2
            )

            rightMargin: leftMargin

            model: filteredModel.values

            delegate: Item {
                id: cellDelegate

                required property var modelData
                required property int index

                width: grid.cellWidth
                height: grid.cellHeight

                Rectangle {
                    id: emojiCell

                    anchors.centerIn: parent

                    width: parent.width - 6
                    height: parent.height - 6

                    radius: Metrics.radiusSM

                    readonly property bool isCurrent:
                    cellDelegate.GridView.isCurrentItem

                    readonly property bool isHovered:
                    cellHover.hovered

                    color: isCurrent
                    ? Qt.alpha(Theme.primary, 0.75)
                    : (isHovered
                    ? Qt.alpha(Theme.surface, 0.6)
                    : "transparent")

                    HoverHandler {
                        id: cellHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    Text {
                        anchors.fill: parent

                        text: cellDelegate.modelData.emoji

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        font.pixelSize: 22
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton

                        onTapped: {
                            if (grid.currentIndex === cellDelegate.index) {
                                EmojiService.copyEmoji(
                                    cellDelegate.modelData.emoji,
                                    controller.closeExpandedState
                                )
                            } else {
                                grid.currentIndex = cellDelegate.index
                            }
                        }
                    }
                }
            }
        } 
    }
}
