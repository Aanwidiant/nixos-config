pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    property var emojiList: []
    property bool isLoaded: false

    QtObject {
        id: internal
        property var items: []
    }

    Process {
        id: loadProcess
        command: ["cat", Quickshell.env("HOME") + "/.local/share/emoji.txt"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (line === "") return;

                let spaceIdx = line.indexOf(" ");
                if (spaceIdx !== -1) {
                    let emoji = line.substring(0, spaceIdx);
                    let name = line.substring(spaceIdx + 1).trim();
                    internal.items.push({ emoji: emoji, name: name });
                } else {
                    internal.items.push({ emoji: line, name: line });
                }
            }
        }

        onExited: {
            service.emojiList = internal.items;
            service.isLoaded = true;
        }
    }

    function copyEmoji(emoji, callback) {
        if (!emoji) return;

        copyProcess.command = ["wl-copy", emoji];
        copyProcess.running = true;

        if (callback) callback();
    }

    Process {
        id: copyProcess
        running: false
    }
}
