import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
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
            searchableList.focusSearch();
        }
    }

    function launch(app) {
        if (!app) return;
        if (app.runInTerminal) {
            Quickshell.execDetached({
                command: ["foot", "-e"].concat(app.command)
            });
        } else {
            app.execute();
        }
    }

    readonly property var masterApps: {
        if (typeof DesktopEntries === "undefined" || !DesktopEntries.applications) {
            return [];
        }

        const manuallyHidden = [
            "base", "gvim", "calc", "draw", "impress", 
            "math", "thunar-bulk-rename", "thunar-settings", 
            "thunar-volman-settings", "writer", "footclient", "foot-server"
        ];

        return Array.from(DesktopEntries.applications.values)
        .filter(d => {
            if (!d || !d.name) return false;
            if (d.hidden || d.noDisplay) return false;
            if (manuallyHidden.includes(d.name) || manuallyHidden.includes(d.id)) return false;
            return true;
        })
        .sort((a, b) => a.name.localeCompare(b.name));
    }

    ScriptModel {
        id: filtered

        values: {
            const q = searchableList.query ? searchableList.query.trim().toLowerCase() : "";

            if (q === "") return root.masterApps;

            return root.masterApps.filter(d => {
                const name       = (d.name || "").toLowerCase();
                const keywords   = (d.keywords || []).join(" ").toLowerCase();
                const categories = (d.categories || []).join(" ").toLowerCase();

                return name.includes(q) || keywords.includes(q) || categories.includes(q);
            });
        }
    }

    CustomListView {
        id: searchableList
        anchors.fill: parent
        anchors.margins: 16
        placeholderText: "Search applications..."
        model: filtered.values

        onItemAccepted: (appData, index) => {
            if (appData) {
                root.launch(appData);
                controller.closeExpandedState();
            }
        }

        onQueryChanged: {
            searchableList.currentIndex = filtered.values.length > 0 ? 0 : -1;
        }

        delegate: Rectangle {
            id: entry
            required property var modelData
            required property int index

            width: searchableList.listView ? searchableList.listView.width : parent.width
            height: 42
            radius: Metrics.radiusMD

            readonly property bool isCurrent: ListView.isCurrentItem
            readonly property bool isHovered: hoverHandler.hovered

            color: isCurrent 
            ? Qt.alpha(Theme.primary, 0.75) 
            : (isHovered ? Qt.alpha(Theme.surface, 0.6) : "transparent")

            Behavior on color { ColorAnimation { duration: 150 } }

            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: {
                    if (searchableList.currentIndex === entry.index) {
                        root.launch(entry.modelData);
                        controller.closeExpandedState();
                    } else {
                        searchableList.currentIndex = entry.index;
                    }
                }
            } 

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: Metrics.spacingLG

                IconImage {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    source: Quickshell.iconPath(entry.modelData.icon || "", true)
                }

                Text {
                    Layout.fillWidth: true
                    text: entry.modelData.name || ""
                    color: entry.ListView.isCurrentItem ? Theme.foreground : Theme.primary 
                    font.pixelSize: Metrics.textMD
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
