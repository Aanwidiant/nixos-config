pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

QtObject {
    id: service

    // --- 1. ADAPTER RESOLUTION (Tetap dipertahankan karena robust) ---
    readonly property var bt: Bluetooth
    readonly property var defaultAdapter: bt ? bt.defaultAdapter : null
    readonly property var firstAdapter: (bt && bt.adapters && bt.adapters.count > 0) ? bt.adapters.get(0) : null
    readonly property var activeAdapter: defaultAdapter || firstAdapter

    // --- 2. INTI STATE (Hanya yang paling sering dipakai di UI) ---
    property bool adapterAvailable: activeAdapter !== null
    property bool bluetoothEnabled: activeAdapter ? activeAdapter.enabled : false
    property bool isScanning: activeAdapter ? activeAdapter.discovering : false

    // --- 3. MODEL PERANGKAT ---
    readonly property var devicesModel: bt ? bt.devices : null

    // --- 4. SIGNALS ---
    signal pairingFailed(string address, string error)

    // --- 5. OBSERVER MINIMAL (Hanya untuk perubahan hardware adapter) ---
    property Connections adapterWatcher: Connections {
        target: bt
        function onDefaultAdapterChanged() {
            console.log("[BluetoothService] ⚡ Adapter default berubah:", service.activeAdapter ? service.activeAdapter.name : "null")
        }
    }

    // --- 6. ADAPTER METHODS ---
    
    function toggleBluetooth() {
        if (!activeAdapter) return console.warn("[BluetoothService] Adapter tidak tersedia")
        console.log("[BluetoothService] Toggle Bluetooth:", !bluetoothEnabled)
        activeAdapter.enabled = !bluetoothEnabled
        if (!bluetoothEnabled) stopDiscovery()
    }

    function startDiscovery() {
        if (!activeAdapter || !bluetoothEnabled) return console.warn("[BluetoothService] Gagal scan: Adapter mati/tidak ada")
        console.log("[BluetoothService] 🔍 Memulai discovery (auto-stop 10s)")
        activeAdapter.discovering = true
        scanTimer.restart()
        // Opsional: aktifkan discoverable sementara agar bisa saling menemukan
        // activeAdapter.discoverable = true 
    }

    function stopDiscovery() {
        if (!activeAdapter) return
        console.log("[BluetoothService] ⏹️ Menghentikan discovery")
        activeAdapter.discovering = false
        scanTimer.stop()
    }

    function setAdapterName(newName) {
        if (!activeAdapter || !newName.trim()) return false
        console.log("[BluetoothService] 📝 Mengubah nama adapter ke:", newName.trim())
        activeAdapter.name = newName.trim()
        return true
    }

    // --- 7. DEVICE METHODS (Dengan logging untuk debugging) ---
    
    function connectDevice(dev) { 
        if (!dev) return
        console.log("[BluetoothService] 🔗 Connect:", dev.name)
        dev.connect() 
    }
    
    function disconnectDevice(dev) { 
        if (!dev) return
        console.log("[BluetoothService] 🔌 Disconnect:", dev.name)
        dev.disconnect() 
    }
    
    function pairDevice(dev) { 
        if (!dev) return
        console.log("[BluetoothService] 🔐 Pairing:", dev.name)
        dev.pair() 
    }
    
    function removeDevice(dev) { 
        if (!dev) return
        console.log("[BluetoothService] 🗑️ Forget:", dev.name)
        dev.forget() 
    }
    
    function unpairDevice(dev) { service.removeDevice(dev) }

    function setTrusted(dev, state) {
        if (!dev) return
        try { 
            console.log("[BluetoothService] 🔒 Set trusted:", state, "for", dev.name)
            dev.trusted = state 
        } catch (e) { 
            console.warn("[BluetoothService] Gagal set trusted:", e) 
        }
    }

    // --- 8. HELPERS ---

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

    // --- 9. TIMERS ---
    property Timer scanTimer: Timer {
        interval: 3000 // 3 detik
        onTriggered: service.stopDiscovery()
    }
}
