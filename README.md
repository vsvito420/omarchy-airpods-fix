# AirPods fix for Omarchy

A bar widget and script that bring AirPods back to life on Linux when they are
**connected but silent**: one click reconnects, restores the A2DP profile and routes audio to them.

Tested with AirPods Pro 2 (Intel BE200, BlueZ 5.87, PipeWire 1.6) and the
[omapods](https://github.com/thisisgm/omarchy-pods) widget with its modified
[librepods](https://github.com/kavishdevar/librepods) daemon.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/vsvito420/omarchy-airpods-fix/main/install.sh | bash
```

or `git clone https://github.com/vsvito420/omarchy-airpods-fix && ./omarchy-airpods-fix/install.sh`

Puts `airpods-fix` into `~/.local/bin`, the widget into `~/.config/omarchy/plugins/` and adds it to the bar
(next to the omapods widget if present).

## Usage

- **Widget** `vito.airpods-fix`: normal = AirPods are the active output, colored = connected but not active (click),
  grey = disconnected
- **Left click** runs the fix, **right click** opens the audio panel
- **Script** `airpods-fix`: Bluetooth on → connect (3 tries) → restart librepods if it lost the device →
  A2DP profile (AAC → SBC-XQ → SBC) → default output, move streams, unmute → notification
