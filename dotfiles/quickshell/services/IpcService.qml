pragma Singleton
import QtQuick
import Quickshell.Io
import "../theme"

Item {
    id: root

    signal requestOpenLauncher()
    signal requestPowerSystem()
    signal requestPowerProfile()
    signal requestNetwork()
    signal requestBluetooth()
    signal requestControlCenter()
    signal requestClipboard()
    signal requestKeybinds()
    signal requestEmoji()

    property bool stayVisible: true

    IpcHandler {
        target: "island" 

        function openLauncher(): void {
            root.requestOpenLauncher()
        }

        function openPowerSystem(): void {
            root.requestPowerSystem()
        }

        function openPowerProfile(): void {
            root.requestPowerProfile() 
        }

        function volumeUp(): void { 
            VolumeService.increaseVolume(0.05) 
        }

        function volumeDown(): void { 
            VolumeService.decreaseVolume(0.05)
        }

        function volumeMute(): void { 
            VolumeService.toggleMute() 
        }

        function volumeUpFine(): void { 
            VolumeService.increaseVolume(0.01)
        }

        function volumeDownFine(): void { 
            VolumeService.decreaseVolume(0.01)
        }

        function brightnessUp(): void { 
            BrightnessService.increase(0.05)
        }

        function brightnessDown(): void { 
            BrightnessService.decrease(0.05)
        }

        function brightnessUpFine(): void { 
            BrightnessService.increase(0.01)
        }

        function brightnessDownFine(): void { 
            BrightnessService.decrease(0.01)
        }

        function micMute(): void { 
            MicrophoneService.toggleMute() 
        }

        function openControlCenter(): void { 
            root.requestControlCenter() 
        }

        function openClipboard(): void { 
            root.requestClipboard() 
        }

        function toggleNightLight(): void { 
            NightLightService.toggle() 
        }

        function toggleIdle(): void { 
            IdleService.toggle() 
        } 

        function toggleTouchpad(): void { 
            TouchpadService.toggle() 
        }

        function toggleAirplane(): void { 
            AirplaneService.toggle() 
        }

        function openKeybinds(): void { 
            root.requestKeybinds()  
        }

        function openEmoji(): void { 
            root.requestEmoji()  
        }

        function reloadTheme(): void {
            Theme.themeFile.reload()
        }

        function toggleStayVisible(): bool {
            root.stayVisible = !root.stayVisible
            return root.stayVisible
        }
    }
}
