import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
PanelWindow {
    id: root
    // Theme
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#444b6a"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property color colGreen: "#9ece6a"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 18
    property int menuSize: 14
    // System data
    property int cpuUsage: 0
    property int memUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    // Wifi data
    property bool wifiEnabled: true
    property string wifiSsid: ""
    property var wifiNets: []
    // Bluetooth adapter, from Quickshell.Bluetooth
    readonly property var btAdapter: Bluetooth.defaultAdapter
    // Processes and timers here...
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 40
    color: root.colBg
    margins {
        top: 15
        left: 20
        right: 20
    }
    // nmcli -t prints colon separated fields, one network per line
    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SIGNAL,SSID", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var nets = []
                var active = ""
                var lines = text.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    if (!lines[i]) continue
                    var parts = lines[i].split(":")
                    var ssid = parts.slice(2).join(":").replace(/\\:/g, ":")
                    if (!ssid) continue
                    if (nets.some(n => n.ssid === ssid)) continue
                    if (parts[0] === "yes") active = ssid
                    nets.push({ ssid: ssid, signal: parseInt(parts[1]), active: parts[0] === "yes" })
                }
                root.wifiNets = nets
                root.wifiSsid = active
            }
        }
        Component.onCompleted: running = true
    }
    // Is the wifi radio on at all
    Process {
        id: wifiRadioProc
        command: ["nmcli", "-t", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
        Component.onCompleted: running = true
    }
    // Reused for connect / radio toggle, then refreshes the list
    Process {
        id: wifiAction
        onRunningChanged: {
            if (!running) {
                wifiRadioProc.running = true
                wifiProc.running = true
            }
        }
    }
    function wifiRun(args) {
        wifiAction.command = args
        wifiAction.running = true
    }
    // Click anywhere else to dismiss
    HyprlandFocusGrab {
        id: grab
        windows: [ root, wifiPopup, btPopup ]
        onCleared: {
            wifiPopup.visible = false
            btPopup.visible = false
        }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8
        // Workspaces
        Repeater {
            model: 5
            Text {
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                text: index + 1
                color: isActive ? root.colCyan : (ws ? root.colBlue : root.colMuted)
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }
        Item { Layout.fillWidth: true }
        // Wifi
        Text {
            id: wifiBtn
            text: "Wifi: " + (root.wifiEnabled ? (root.wifiSsid || "none") : "off")
            color: root.wifiSsid ? root.colGreen : root.colMuted
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    btPopup.visible = false
                    wifiPopup.visible = !wifiPopup.visible
                    if (wifiPopup.visible) {
                        wifiRadioProc.running = true
                        wifiProc.running = true
                    }
                    grab.active = wifiPopup.visible
                }
            }
        }
        Rectangle { width: 1; height: 16; color: root.colMuted }
        // Bluetooth
        Text {
            id: btBtn
            text: "BT: " + (root.btAdapter && root.btAdapter.enabled ? "on" : "off")
            color: root.btAdapter && root.btAdapter.enabled ? root.colBlue : root.colMuted
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    wifiPopup.visible = false
                    btPopup.visible = !btPopup.visible
                    grab.active = btPopup.visible
                }
            }
        }
        Rectangle { width: 1; height: 16; color: root.colMuted }
        // CPU
        Text {
            text: "CPU: " + cpuUsage + "%"
            color: root.colYellow
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        Rectangle { width: 1; height: 16; color: root.colMuted }
        // Memory
        Text {
            text: "Mem: " + memUsage + "%"
            color: root.colCyan
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        Rectangle { width: 1; height: 16; color: root.colMuted }
        // Clock
        Text {
            id: clock
            color: root.colBlue
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            }
        }
    }
    // Wifi dropdown
    PopupWindow {
        id: wifiPopup
        visible: false
        color: "transparent"
        implicitWidth: 320
        implicitHeight: wifiCol.implicitHeight + 16
        anchor {
            item: wifiBtn
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            margins.top: 8
        }
        Rectangle {
            anchors.fill: parent
            color: root.colBg
            border { color: root.colMuted; width: 1 }
            radius: 6
            ColumnLayout {
                id: wifiCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2
                Text {
                    text: root.wifiEnabled ? "Wifi is on - click to turn off" : "Wifi is off - click to turn on"
                    color: root.wifiEnabled ? root.colGreen : root.colMuted
                    font { family: root.fontFamily; pixelSize: root.menuSize; bold: true }
                    Layout.fillWidth: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.wifiRun(["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"])
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: root.colMuted }
                Repeater {
                    model: root.wifiNets
                    Text {
                        text: (modelData.active ? "* " : "  ") + modelData.ssid + "  " + modelData.signal + "%"
                        color: modelData.active ? root.colCyan : root.colFg
                        font { family: root.fontFamily; pixelSize: root.menuSize }
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.wifiRun(["nmcli", "device", "wifi", "connect", modelData.ssid])
                                wifiPopup.visible = false
                                grab.active = false
                            }
                        }
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: root.colMuted }
                Text {
                    text: "Rescan"
                    color: root.colYellow
                    font { family: root.fontFamily; pixelSize: root.menuSize; bold: true }
                    Layout.fillWidth: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: wifiProc.running = true
                    }
                }
            }
        }
    }
    // Bluetooth dropdown
    PopupWindow {
        id: btPopup
        visible: false
        color: "transparent"
        implicitWidth: 320
        implicitHeight: btCol.implicitHeight + 16
        anchor {
            item: btBtn
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            margins.top: 8
        }
        Rectangle {
            anchors.fill: parent
            color: root.colBg
            border { color: root.colMuted; width: 1 }
            radius: 6
            ColumnLayout {
                id: btCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2
                Text {
                    text: !root.btAdapter ? "No adapter" : (root.btAdapter.enabled ? "Bluetooth is on - click to turn off" : "Bluetooth is off - click to turn on")
                    color: root.btAdapter && root.btAdapter.enabled ? root.colGreen : root.colMuted
                    font { family: root.fontFamily; pixelSize: root.menuSize; bold: true }
                    Layout.fillWidth: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (root.btAdapter) root.btAdapter.enabled = !root.btAdapter.enabled
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: root.colMuted }
                Repeater {
                    model: root.btAdapter ? root.btAdapter.devices.values : []
                    Text {
                        text: (modelData.connected ? "* " : "  ") + modelData.name
                        color: modelData.connected ? root.colCyan : root.colFg
                        font { family: root.fontFamily; pixelSize: root.menuSize }
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
                        }
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: root.colMuted }
                Text {
                    text: root.btAdapter && root.btAdapter.discovering ? "Stop scanning" : "Scan for devices"
                    color: root.colYellow
                    font { family: root.fontFamily; pixelSize: root.menuSize; bold: true }
                    Layout.fillWidth: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (root.btAdapter) root.btAdapter.discovering = !root.btAdapter.discovering
                    }
                }
            }
        }
    }
}