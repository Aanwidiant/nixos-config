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

            // Status visual
            readonly property bool isCurrent: ListView.isCurrentItem
            readonly property bool isHovered: hoverHandler.hovered

            width: searchableList.listView ? searchableList.listView.width : parent.width
            height: 42
            radius: Metrics.radiusMD

            // Warna latar belakang terpisah untuk hover dan item aktif
            color: isCurrent 
            ? Qt.alpha(Theme.primary, 0.75) 
            : (isHovered ? Qt.alpha(Theme.surface, 0.6) : "transparent")

            Behavior on color { ColorAnimation { duration: 150 } }

            // HoverHandler HANYA mengurus indikator kursor dan efek visual hover
            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }

            // TapHandler dengan logika 2-langkah (Pilih -> Eksekusi)
            TapHandler {
                acceptedButtons: Qt.LeftButton
                onTapped: {
                    if (searchableList.currentIndex === entry.index) {
                        // KLIK KEDUA: Item sudah aktif -> Konfirmasi & pilih font
                        FontService.selectFont(entry.modelData, controller.closeExpandedState);
                    } else {
                        // KLIK PERTAMA: Hanya pilih/fokus ke item ini
                        searchableList.currentIndex = entry.index;
                    }
                }
            }

            // Struktur Layout sederhana & konsisten seperti launcher
            Item {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                Text {
                    id: fontText
                    anchors.fill: parent
                    text: entry.modelData
                    color: entry.ListView.isCurrentItem ? Theme.foreground : Theme.primary
                    font.family: entry.modelData // Tetap menggunakan live preview font
                    font.pixelSize: Metrics.textMD
                    font.weight: Font.Medium
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight // Memotong rapi teks panjang tanpa mengacaukan gesture
                }
            }
        }
    }
}
