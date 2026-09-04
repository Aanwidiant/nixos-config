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

    implicitWidth: 480
    implicitHeight: 400

    CloseButton {}

    onVisibleChanged: {
        if (!visible) {
            searchableList.reset();
        } else {
            KeybindService.refresh();
            searchableList.focusSearch();
        }
    }

    ScriptModel {
        id: filtered

        values: {
            const allEntries = KeybindService.bindingsList || [];
            const q = searchableList.query.trim().toLowerCase();

            if (q === "") return allEntries;

            return allEntries.filter(item => item.toLowerCase().includes(q));
        }
    }

    CustomListView {
        id: searchableList
        anchors.fill: parent
        anchors.margins: 16
        placeholderText: "Search keybindings..."
        model: filtered.values

        onItemAccepted: (bindData, index) => {
            KeybindService.selectItem(bindData, controller.closeExpandedState);
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

            Flickable {
                id: itemFlickable
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                contentWidth: contentContainer.width
                contentHeight: height
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                clip: true

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        if (searchableList.currentIndex === entry.index) {
                            KeybindService.selectItem(entry.modelData, controller.closeExpandedState);
                        } else {
                            searchableList.currentIndex = entry.index;
                        }
                    }
                }                Item {
                    id: contentContainer
                    height: itemFlickable.height
                    width: Math.max(itemFlickable.width, descText.implicitWidth + keyBadge.implicitWidth + Metrics.spacingMD)

                    Rectangle {
                        id: keyBadge
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        height: 26
                        width: keyText.implicitWidth + 16
                        radius: Metrics.radiusSM
                        color: Qt.alpha(Theme.foreground, 0.15)

                        Text {
                            id: keyText
                            anchors.centerIn: parent
                            text: KeybindService.getKey(entry.modelData)
                            color: entry.ListView.isCurrentItem ? Theme.foreground : Theme.primary
                            font.pixelSize: Metrics.textSM
                            font.weight: Font.Bold
                            font.family: Theme.textFont
                        }
                    }

                    Text {
                        id: descText
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: KeybindService.getDescription(entry.modelData)
                        color: entry.ListView.isCurrentItem ? Theme.foreground : Theme.primary
                        font.pixelSize: Metrics.textMD
                        font.weight: Font.Medium
                        font.family: Theme.textFont
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                    }
                }
            }
        }
    }
}
