pragma Singleton
import QtQuick
import Quickshell

Item {
    id: root

    property string selectedMode: "region" 

    function takeScreenshot(mode) {
        let targetMode = mode || root.selectedMode;

        Quickshell.execDetached([
            "my-cmd-screenshot", targetMode
        ]);
    }
}
