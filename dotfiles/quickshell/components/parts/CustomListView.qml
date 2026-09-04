import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"

ColumnLayout {
    id: searchableRoot

    property alias query: searchInput.text
    property alias placeholderText: searchInput.placeholderText
    property alias model: listView.model
    property alias delegate: listView.delegate
    property alias currentIndex: listView.currentIndex
    property alias count: listView.count
    property alias listView: listView

    signal itemAccepted(var currentItemData, int currentIndex)

    spacing: Metrics.spacingLG

    function reset() {
        searchInput.clear();
        if (listView.count > 0) {
            listView.currentIndex = 0;
        }
    }

    function focusSearch() {
        searchInput.forceActiveFocus();
    }

    RowLayout {
        Layout.fillWidth: true
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
                    placeholderText: "Search..."
                    placeholderTextColor: Theme.muted
                    color: Theme.foreground 
                    font.pixelSize: Metrics.textMD
                    font.family: Theme.textFont
                    padding: 0

                    background: Rectangle { color: "transparent" }

                    Keys.onPressed: (event) => {
                        const ctrl = event.modifiers & Qt.ControlModifier;

                        if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && ctrl)) {
                            event.accepted = true;
                            if (listView.currentIndex > 0) {
                                listView.currentIndex--;
                                listView.positionViewAtIndex(listView.currentIndex, ListView.Contain);
                            }
                        } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && ctrl)) {
                            event.accepted = true;
                            if (listView.currentIndex < listView.count - 1) {
                                listView.currentIndex++;
                                listView.positionViewAtIndex(listView.currentIndex, ListView.Contain);
                            }
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = true;
                            if (listView.currentItem) {
                                searchableRoot.itemAccepted(listView.currentItem.modelData, listView.currentIndex);
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
                            searchableRoot.reset();
                            searchInput.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: listView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: Metrics.spacingMD

        highlightRangeMode: ListView.NoHighlightRange
        highlightMoveDuration: 0 

        Keys.onReturnPressed: {
            if (currentItem) {
                searchableRoot.itemAccepted(currentItem.modelData, currentIndex);
            }
        }
    }
}
