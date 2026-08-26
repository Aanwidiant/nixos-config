import QtQuick
import Quickshell
import Quickshell.Wayland
import "services"
import "components/parts"

ShellRoot {
    id: root

    LockService {
        id: lockService

        onUnlocked: {
            lock.locked = false;
            Qt.quit(); 
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                service: lockService
            }
        }
    }
}
