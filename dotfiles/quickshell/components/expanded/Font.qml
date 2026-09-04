import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
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
            searchableList.reset();
        } else {
            FontService.refresh();
            searchableList.focusSearch();
        }
    }

    ScriptModel {
        id: filtered

        values: {
            const allEntries = FontService.fontsList || [];
            const q = searchableList.query.trim().toLowerCase();

            if (q === "") return allEntries;

            return allEntries.filter(item => item.toLowerCase().includes(q));
        }
    }

    CustomListView {
        id: searchableList
        anchors.fill: parent
        anchors.margins: 16
        placeholderText: "Search monospace fonts..."
        model: filtered.values

        onItemAccepted: (fontName, index) => {
            FontService.selectFont(fontName, controller.closeExpandedState);
        }

        onQueryChanged: {
            searchableList.currentIndex = filtered.values.length > 0 ? 0 : -1;
        }

        delegate: Rectangle {
            id: entry
            required property var modelData
            required property int index

            readonly property bool isCurrent: ListView.isCurrentItem
            readonly property bool isHovered: hoverHandler.hovered

            width: searchableList.listView ? searchableList.listView.width : parent.width
            height: 42
            radius: Metrics.radiusMD

            color: isCurrent 
            ? Qt.alpha(Theme.primary, 0.75) 
            : (isHovered ? Qt.alpha(Theme.surface, 0.6) : "transparent")

            Behavior on color { ColorAnimation { duration: 150 } }

            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                acceptedButtons: Qt.LeftButton
                onTapped: {
                    if (searchableList.currentIndex === entry.index) {
                        FontService.selectFont(entry.modelData, controller.closeExpandedState);
                    } else {
                        searchableList.currentIndex = entry.index;
                    }
                }
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                Text {
                    id: fontText
                    anchors.fill: parent
                    text: entry.modelData
                    color: entry.ListView.isCurrentItem ? Theme.foreground : Theme.primary
                    font.family: entry.modelData 
                    font.pixelSize: Metrics.textMD
                    font.weight: Font.Medium
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight 
                }
            }
        }
    }
}
