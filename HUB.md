# AirPods unter Omarchy

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="72" height="72" role="img" aria-label="Icon AirPods-Fix">
  <defs><linearGradient id="apbg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#2b6fd0"/><stop offset=".55" stop-color="#1499c9"/><stop offset="1" stop-color="#0fb58a"/></linearGradient></defs>
  <rect width="128" height="128" rx="28" fill="url(#apbg)"/>
  <g fill="#fff"><ellipse cx="44" cy="46" rx="15" ry="17"/><rect x="45" y="50" width="10" height="44" rx="5"/><ellipse cx="84" cy="46" rx="15" ry="17"/><rect x="73" y="50" width="10" height="44" rx="5"/></g>
  <g fill="#1499c9"><circle cx="38" cy="44" r="4"/><circle cx="90" cy="44" r="4"/></g>
</svg>

Ein Bar-Widget für Omarchy, das AirPods mit einem Klick wieder zum Klingen bringt, wenn sie
verbunden, aber stumm sind. Dahinter steckt das Skript `airpods-fix`, das alles der Reihe nach repariert.

Getestet mit AirPods Pro 2 (Intel BE200, BlueZ 5.87, PipeWire 1.6) und dem
[omapods](https://github.com/thisisgm/omarchy-pods)-Widget, das einen modifizierten
[librepods](https://github.com/kavishdevar/librepods)-Daemon mitbringt.

## Was es zeigt

- **Widget** [`vito.airpods-fix`](plugins/vito.airpods-fix/BarWidget.qml)
  - 󰋋 normal – AirPods sind die aktive Ausgabe
  - 󰋋 farbig – verbunden, aber nicht aktiv → klicken
  - 󰟎 grau – getrennt
- **Linksklick** – repariert
- **Rechtsklick** – öffnet das Audio-Panel

## Installieren

```bash
curl -fsSL https://raw.githubusercontent.com/vsvito420/omarchy-airpods-fix/main/install.sh | bash
```

Legt `airpods-fix` nach `~/.local/bin`, das Widget nach `~/.config/omarchy/plugins/` und trägt
es in die Bar ein (neben dem omapods-Widget, falls vorhanden).

## So funktioniert's

- **Skript:** [`airpods-fix`](bin/airpods-fix)
  1. Bluetooth an, AirPods verbinden (3 Versuche, zwischendurch einmal trennen)
  2. librepods neu starten, wenn es das Gerät verloren hat
  3. A2DP-Profil aktivieren (AAC → SBC-XQ → SBC), notfalls WirePlumber neu starten
  4. AirPods als Standardausgabe, alle Streams dorthin verschieben, Stummschaltungen aufheben
  5. Ergebnis als Benachrichtigung
- **Widget:** prüft, ob die AirPods verbunden und die Standardausgabe sind, und startet das Skript per Klick

## Warum sie stumm sind

- **Symptome**
  - AirPods sind verbunden, tauchen im Sound-Menü aber **nicht als Ausgabe** auf
  - stattdessen sieht man nur ein „Mikrofon“ (`bluez_input.…`)
  - nach dem Rausnehmen und Wiedereinsetzen bleibt es still – nur ein Reset hilft
- **Ohrerkennung schaltet das Profil ab**
  - librepods setzt das Bluetooth-Audio-Profil auf `off`, sobald beide Pods aus dem Ohr sind
  - nach einem Verbindungsabbruch verliert der Daemon das Gerät (`connected device = ""`)
    und schaltet das Profil **nie wieder ein**
- **Das „Mikrofon“ ist keins**
  - eine WirePlumber-Regel mit `bluez5.auto-connect = [ a2dp_sink a2dp_source ]`
    erzeugt bei jedem Bluetooth-Gerät auch einen A2DP-Eingang
  - der bleibt sichtbar, auch wenn die Ausgabe aus ist
- **Abbrüche kurz nach dem Verbinden**
  - passen zur automatischen Geräte-Umschaltung von Apple (iPhone holt sich die AirPods)
  - iPhone → Bluetooth → AirPods → „Mit diesem iPhone verbinden“ →
    *Wenn zuletzt mit diesem iPhone verbunden*
- **Und manchmal ist es einfach der Browser**
  - der Chromium-Stream war selbst stummgeschaltet (`pactl list sink-inputs` → `Mute: yes`)

<div class="callout tip" markdown="1">
**Schnelle Hilfe ohne Widget**

- `systemctl --user restart librepods` – Daemon neu, Profil kommt zurück
- `pactl set-card-profile bluez_card.<MAC_mit_> a2dp-sink` – A2DP von Hand aktivieren
- `librepods-ctl ear:off` – Ohrerkennung aus, dann schaltet nichts mehr die Ausgabe ab
</div>

## Siehe auch

- [[Omarchy]] – alle Erweiterungen und das Installationsskript
- [[Agents-Leiste mit OpenRouter]], [[Energieprofil-Tacho für die Bar]]
