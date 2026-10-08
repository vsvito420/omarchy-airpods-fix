import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "vito.airpods-fix"

  // 0 = AirPods are the active output, 1 = connected but not playing, 2 = disconnected
  property int podState: 2
  readonly property bool fixing: fixProc.running

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() {
    if (!checkProc.running && !fixProc.running) checkProc.running = true
  }

  function fix() {
    if (!fixProc.running) fixProc.running = true
  }

  Process {
    id: checkProc
    command: ["bash", "-c",
      "mac=$(bluetoothctl devices Paired | awk '/AirPods/ {print $2; exit}'); " +
      "[ -n \"$mac\" ] && bluetoothctl info \"$mac\" | grep -q 'Connected: yes' || exit 2; " +
      "pactl get-default-sink | grep -q \"bluez_output.${mac//:/_}\" || exit 1; " +
      "[ \"$(pactl get-sink-mute @DEFAULT_SINK@)\" = 'Mute: no' ] || exit 1; exit 0"]
    onExited: function(exitCode) { root.podState = exitCode }
  }

  Process {
    id: fixProc
    command: ["airpods-fix"]
    onExited: root.refresh()
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.fixing ? "󰑓" : (root.podState === 2 ? "󰟎" : "󰋋")
    active: root.fixing || root.podState === 1
    dimmed: !root.fixing && root.podState === 2
    tooltipText: root.fixing ? "AirPods werden repariert…"
      : root.podState === 0 ? "AirPods aktiv – Klick: neu reparieren"
      : root.podState === 1 ? "AirPods verbunden, aber nicht aktiv – Klick zum Fixen"
      : "AirPods getrennt – Klick zum Verbinden"
    onPressed: function(b) {
      if (b === Qt.RightButton) root.bar.run("omarchy-shell shell toggle omarchy.audio")
      else root.fix()
    }
  }
}
