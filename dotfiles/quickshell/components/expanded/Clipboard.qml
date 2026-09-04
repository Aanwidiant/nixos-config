import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../../services"
import "../../theme"
import "../parts"

Item {
    id: root

    implicitWidth: 500
    implicitHeight: 400

    CloseButton {}

    onVisibleChanged: {
        if (!visible) {
            searchableList.reset();
        } else {
            ClipboardService.refresh();
            searchableList.focusSearch();
        }
    }

    ScriptModel {
        id: filtered

        values: {
            const allEntries = ClipboardService.historyList || [];
            const q = searchableList.query.trim().toLowerCase();

            if (q === "") return allEntries;

            return allEntries.filter(item => item.toLowerCase().includes(q));
        }
    }

    CustomListView {
        id: searchableList
        anchors.fill: parent
        anchors.margins: 16
        placeholderText: "Search clipboard history..."
        model: filtered.values

        onItemAccepted: (clipData, index) => {
            ClipboardService.selectAndPaste(clipData, controller.closeExpandedState);
        }

        onQueryChanged: {
            searchableList.currentIndex = filtered.values.length > 0 ? 0 : -1;
        }

        delegate: Rectangle {
            id: entry
            required property var modelData
            required property int index

            property bool isImg: ClipboardService.isImage(modelData)
            property string clipId: ClipboardService.getId(modelData)
            property string imagePath: "/tmp/cliphist_preview_" + clipId + ".png"
            property bool imageReady: false

            readonly property bool isCurrent: ListView.isCurrentItem
            readonly property bool isHovered: hoverHandler.hovered

            width: searchableList.listView ? searchableList.listView.width : parent.width
            height: isImg ? 120 : 42
            radius: Metrics.radiusMD

            color: isCurrent 
            ? Qt.alpha(Theme.primary, 0.75) 
            : (isHovered ? Qt.alpha(Theme.surface, 0.6) : "transparent")

            Behavior on color { ColorAnimation { duration: 150 } }

            Process {
                id: imageDecoder
                running: entry.isImg
                command: ["bash", "-c", ClipboardService.getDecodeCommand(entry.modelData, entry.imagePath)]
                onExited: {
                    entry.imageReady = true;
                }
            }

            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }

            Flickable {
                id: itemFlickable
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                contentWidth: contentRow.implicitWidth
                contentHeight: height
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                clip: true

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        if (searchableList.currentIndex === entry.index) {
                            ClipboardService.selectAndPaste(entry.modelData, controller.closeExpandedState);
                        } else {
                            searchableList.currentIndex = entry.index;
                        }
                    }
                } 
                Row {
                    id: contentRow
                    height: parent.height
                    spacing: Metrics.spacingMD

                    Image {
                        visible: entry.isImg && entry.imageReady
                        source: entry.imageReady ? "file://" + entry.imagePath : ""
                        fillMode: Image.PreserveAspectFit
                        height: parent.height - 8
                        width: 160
                        cache: false
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: !entry.isImg
                        text: ClipboardService.getDisplayText(entry.modelData)
                        color: entry.ListView.isCurrentItem ? Theme.foreground : Theme.primary
                        font.pixelSize: Metrics.textMD
                        font.weight: Font.Medium
                        font.family: Theme.textFont
                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Text.NoWrap
                    }
                }
            }
        }
    }
}
