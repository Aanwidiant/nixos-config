pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

QtObject {
    id: service

    readonly property var bt: Bluetooth
    readonly property var defaultAdapter: bt ? bt.defaultAdapter : null
    readonly property var firstAdapter: (bt && bt.adapters && bt.adapters.count > 0) ? bt.adapters.get(0) : null
    readonly property var activeAdapter: defaultAdapter || firstAdapter

    property bool adapterAvailable: activeAdapter !== null
    property bool bluetoothEnabled: activeAdapter ? activeAdapter.enabled : false
    property bool isScanning: activeAdapter ? activeAdapter.discovering : false

    readonly property var devicesModel: bt ? bt.devices : null

    signal pairingFailed(string address, string error)

    property Connections adapterWatcher: Connections {
        target: bt
        function onDefaultAdapterChanged() {
            console.log("[BluetoothService] Adapter default berubah:", service.activeAdapter ? service.activeAdapter.name : "null")
        }
    }

    function toggleBluetooth() {
        if (!activeAdapter) return console.warn("[BluetoothService] Adapter tidak tersedia")
        console.log("[BluetoothService] Toggle Bluetooth:", !bluetoothEnabled)
        activeAdapter.enabled = !bluetoothEnabled
        if (!bluetoothEnabled) stopDiscovery()
    }

    function startDiscovery() {
        if (!activeAdapter || !bluetoothEnabled) return console.warn("[BluetoothService] Gagal scan: Adapter mati/tidak ada")
        console.log("[BluetoothService] Memulai discovery (auto-stop 10s)")
        activeAdapter.discovering = true
        scanTimer.restart()
    }

    function stopDiscovery() {
        if (!activeAdapter) return
        console.log("[BluetoothService] Menghentikan discovery")
        activeAdapter.discovering = false
        scanTimer.stop()
    }

    function setAdapterName(newName) {
        if (!activeAdapter || !newName.trim()) return false
        console.log("[BluetoothService] Mengubah nama adapter ke:", newName.trim())
        activeAdapter.name = newName.trim()
        return true
    }

    function connectDevice(dev) { 
        if (!dev) return
        console.log("[BluetoothService] Connect:", dev.name)
        dev.connect() 
    }

    function disconnectDevice(dev) { 
        if (!dev) return
        console.log("[BluetoothService] Disconnect:", dev.name)
        dev.disconnect() 
    }

    function pairDevice(dev) { 
        if (!dev) return
        console.log("[BluetoothService] Pairing:", dev.name)
        dev.pair() 
    }

    function removeDevice(dev) { 
        if (!dev) return
        console.log("[BluetoothService] Forget:", dev.name)
        dev.forget() 
    }

    function unpairDevice(dev) { service.removeDevice(dev) }

    function setTrusted(dev, state) {
        if (!dev) return
        try { 
            console.log("[BluetoothService] Set trusted:", state, "for", dev.name)
            dev.trusted = state 
        } catch (e) { 
            console.warn("[BluetoothService] Gagal set trusted:", e) 
        }
    }

    function getAdapterStateText() {
        if (!activeAdapter || !activeAdapter.state) return "Unknown"
        return activeAdapter.state.toString()
    }

    function getDeviceIcon(dev) {
        if (!dev) return "bluetooth"
        if (dev.icon && dev.icon !== "" && dev.icon !== "bluetooth") return dev.icon

        const lowerName = (dev.name || "").toLowerCase()
        if (lowerName.includes("headphone") || lowerName.includes("headset") || lowerName.includes("buds")) return "audio-headset"
        if (lowerName.includes("keyboard")) return "input-keyboard"
        if (lowerName.includes("mouse")) return "input-mouse"
        if (lowerName.includes("phone") || lowerName.includes("galaxy") || lowerName.includes("iphone")) return "phone"
        return "bluetooth"
    }

    function getDeviceStatusText(dev) {
        if (!dev) return ""
        const stateStr = dev.state ? dev.state.toString() : ""
        if (stateStr === "Connecting") return "Menghubungkan..."
        if (stateStr === "Disconnecting") return "Memutuskan..."
        if (dev.connected) return "Terhubung"
        if (dev.paired) return "Dipasangkan"
        return "Tersedia"
    }

    property Timer scanTimer: Timer {
        interval: 3000
        onTriggered: service.stopDiscovery()
    }
}
