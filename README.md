# FakeSim Termux — Magisk Module

A module that takes advantage of Android's demo mode, simulating network type, signal level, NFC icon, real-time battery and clock sync, and more.

---

## 📱 Compatibility / Compatibilidad

**✅ Tested on / Probado en:**
- DotOS (Android 11)
- BlissOS (Android 13) — WiFi hide bug fixed in v1.5.6.3+
- e/OS (Android 11) — very compatible, recommended to use GravityBox for battery icon
- VoltageOS (Android 16) — bug fixed

**❌ Does not work on / No funciona en:**
- HyperOS, MIUI, Funtouch, Origin

**⚠️ May work, not tested / Podría funcionar, no probado:**
- NokiaUI, HelloUI (Motorola), OxygenOS, and any AOSP-based ROM

---

## ✨ Features / Características

- 📶 Simulate any network type (GPRS, EDGE, 3G, H+, LTE, 5G and more)
- 📡 Special networks: Satellite SOS, Satellite-WiFi, Starlink, e+, gprs+, hspa++
- 🔋 Real-time battery level and charging status sync
- 🕐 Real-time clock sync (no more frozen clock in demo mode)
- 📶 Independent signal level per SIM slot (`-l` and `-l2`)
- 📵 WiFi icon always hidden — only mobile signal is shown
- 📳 NFC icon active by default
- 🎬 Record mode — clean status bar preset for screenshots/videos
- 📅 Network schedule by time of day (editable config file)
- ✅ Android 11 to 16 compatible

> The TTY icon is active by default / El icono TTY está activo por defecto

---

## ⚙️ Installation / Instalación

1. Download the `.zip` file
2. Open Magisk → Modules → Install from storage
3. Select the `.zip` and reboot
4. Use `minenet` from Termux to control the simulation

---

## 🛠️ Commands / Comandos (`minenet`)

### Basic usage / Uso básico

```sh
minenet -t [type] -l [level] -l2 [slot2 level] -c [carrier]
```

| Flag | Description |
|------|-------------|
| `-t` / `--type` | Network type for slot 1 |
| `-t2` / `--type2` | Network type for slot 2 independently |
| `-l` / `--level` | Signal level for slot 1 (0–4) |
| `-l2` / `--level2` | Signal level for slot 2 independently (0–4) |
| `-c` / `--carrier` | Carrier name shown in status bar |
| `-h` | Show help |

### Examples / Ejemplos

```sh
# 5G full signal
minenet -t 5g -l 4

# LTE with carrier name
minenet -t lte -l 3 -c "Movistar"

# Different type and level per slot
minenet -t lte -l 4 -t2 3g -l2 2

# Different type, same level
minenet -t 5g -l 4 -t2 h+

# Without -t2, slot 2 copies slot 1 type
minenet -t lte -l 3
```

### Special network commands / Comandos especiales

```sh
minenet -s          # Satellite SOS (Android 16+ only)
minenet -sw         # Satellite-WiFi (Android 16+ only)
minenet -starlink   # Starlink (Android 16+ only)
minenet -e+         # Enhanced EDGE
minenet -gprs+      # Enhanced GPRS
minenet -hspa++     # Enhanced HSPA+
```

### Network types / Tipos de red

| Command | Icon shown |
|---------|-----------|
| `g` | GPRS |
| `e` | EDGE |
| `1x` | 1X |
| `3g` | 3G |
| `h` | H (HSPA) |
| `h+` | H+ (HSPA+) |
| `lte` | LTE |
| `lte+` | LTE+ |
| `5ge` | 5G Evolution |
| `5g` | 5G |
| `5g+` | 5G+ |
| `s` | Satellite SOS |
| `sw` | Satellite-WiFi |
| `starlink` | Starlink |
| `e+` | Enhanced EDGE ⚗️ |
| `gprs+` | Enhanced GPRS ⚗️ |
| `hspa++` | Enhanced HSPA+ ⚗️ |

---

## 🎬 Record Mode / Modo Grabación

Activates a clean preset for screenshots or screen recordings:
- Battery forced to 100%, unplugged
- LTE full signal
- Clock fixed at 12:00
- No carrier name, no roaming

```sh
# Activate / Activar
touch /data/local/tmp/minenet/record

# Deactivate / Desactivar
rm /data/local/tmp/minenet/record
```

---

## 📳 NFC Icon / Icono NFC

Active by default. To hide it:

```sh
# Hide / Ocultar
touch /data/local/tmp/minenet/nonfc

# Show again / Mostrar de nuevo
rm /data/local/tmp/minenet/nonfc
```

---

## 📅 Network Schedule / Horario de red

A config file is created automatically at:
```
/data/local/tmp/minenet/schedule.conf
```

Default schedule:
```
# HOUR_START  HOUR_END  TYPE  LEVEL
00            07        3g    2      # Late night
07            14        lte   4      # Morning
14            23        5g    4      # Afternoon
23            24        lte   3      # Night
```

If a manual `type` file exists, it takes priority over the schedule.

---

## 📸 Screenshots / Capturas

<img width="720" height="1600" alt="39066" src="https://github.com/user-attachments/assets/cbc4218f-a4b8-4976-b5e4-b6212b5b7732" />
<img width="720" height="1600" alt="39065" src="https://github.com/user-attachments/assets/92494335-a79e-465a-af0c-e707e6d21080" />
<img width="720" height="1600" alt="39064" src="https://github.com/user-attachments/assets/86f251e7-f113-4f5f-9ecb-d2d5bf7894bf" />
<img width="720" height="1600" alt="39067" src="https://github.com/user-attachments/assets/23ec0f7c-db46-4fc0-ab87-b2e8adf52550" />
<img width="720" height="1600" alt="39068" src="https://github.com/user-attachments/assets/73d51a71-dad6-4c7e-b239-05540767475e" />
<img width="720" height="1600" alt="39069" src="https://github.com/user-attachments/assets/62e8689f-1ddc-4241-8eb6-0efbf7e1ea16" />
<img width="720" height="1600" alt="39073" src="https://github.com/user-attachments/assets/e197e71c-5784-4a72-850e-dd5080401670" />
<img width="720" height="1600" alt="39070" src="https://github.com/user-attachments/assets/2bb63b3a-8260-4a74-a67f-5dd2ab6a2500" />
<img width="720" height="1600" alt="39071" src="https://github.com/user-attachments/assets/318b8818-56e9-4ec2-80c6-a10f5bce5746" />
<img width="720" height="1600" alt="39072" src="https://github.com/user-attachments/assets/e11d6d22-d7a2-4d6d-810b-f4252609c852" />
<img width="720" height="1600" alt="39074" src="https://github.com/user-attachments/assets/e1a1ac2c-d955-4278-b554-080bfd3ef425" />
<img width="720" height="1600" alt="39075" src="https://github.com/user-attachments/assets/a79fd7af-d8c0-4396-8c66-0b875da2c956" />

---

## 📊 Speed Test Results / Tabla de Velocidades

> 🇪🇸 Las pruebas se realizaron en un **Redmi 9A** usando conexión compartida (Hotspot) de un **Redmi Note 12 Pro 5G** en la banda de **5GHz**.

> 🇺🇸 Tests performed on a **Redmi 9A** using a hotspot connection from a **Redmi Note 12 Pro 5G** on the **5GHz band**.

### 🇪🇸 Español

| Modo de Red | Velocidad Obtenida |
| :--- | :--- |
| **GPRS** | 34 Kbps |
| **EDGE** | 150 Kbps |
| **1X** | 170 Kbps |
| **3G** | 1.8 Mbps |
| **HSPA** | 4.7 Mbps |
| **HSPA+** | 10 Mbps |
| **LTE** | 27 Mbps |
| **LTE+** | 92 Mbps |
| **5G Evolution** | 82 Mbps |
| **5G+** | 91 Mbps |
| **5G** | *Dependerá de tu internet* |

**Redes especiales** *(satélite, satélite wifi y starlink solo en Android 16)*

| Modo de Red | Velocidad Obtenida |
| :--- | :--- |
| **Satélite (SOS)** | 60 Kbps |
| **Satélite-WiFi** *(creado por Minerva)* | 1.73 Mbps |
| **Starlink** | 20.8 Mbps |
| **e+** | 2.7 Mbps |
| **gprs+** | 720 Kbps |
| **hspa++** | 11 Mbps |

> **NOTA:** Los test de redes especiales se hicieron en **Opera Mini**.

> ⚗️ **e+, gprs+ y hspa++ son evoluciones de red ficticias creadas exclusivamente por Minerva para este módulo. No existen en la vida real.**

### 🇺🇸 English

| Network Mode | Speed Achieved |
| :--- | :--- |
| **GPRS** | 34 Kbps |
| **EDGE** | 150 Kbps |
| **1X** | 170 Kbps |
| **3G** | 1.8 Mbps |
| **HSPA** | 4.7 Mbps |
| **HSPA+** | 11 Mbps |
| **LTE** | 27 Mbps |
| **LTE+** | 92 Mbps |
| **5G Evolution** | 82 Mbps |
| **5G+** | 91 Mbps |
| **5G** | *Depends on your internet* |

**Special Networks** *(satellite, satellite-wifi & starlink on Android 16 only)*

| Network Mode | Speed Achieved |
| :--- | :--- |
| **Satellite (SOS)** | 60 Kbps |
| **Satellite-Wi-Fi** *(Minerva's own creation)* | 1.73 Mbps |
| **Starlink** | 20.8 Mbps |
| **e+** | 2.09 Mbps |
| **gprs+** | 630 Kbps |
| **hspa++** | 11 Mbps |

> ⚗️ **e+, gprs+ and hspa++ are fictional network evolutions created exclusively by Minerva for this module. They do not exist in real life.**

> ⚗️ **e+, gprs+ y hspa++ son evoluciones de red ficticias creadas exclusivamente por Minerva para este módulo. No existen en la vida real.**

> ⚠️ **Speeds on WiFi 4 (2.4 GHz) may be lower than these results! / Las velocidades en WiFi 4 (2.4 GHz) pueden ser inferiores a estos resultados!**

---

## 🌐 App Compatibility Tests / Pruebas de compatibilidad

### Discord

| Red / Network | 🇪🇸 Español | 🇺🇸 English |
|---|---|---|
| G (GPRS) | Abre perfectamente, se puede chatear y enviar mensajes sin mucha demora (app móvil). | Opens perfectly, you can chat and send messages without much delay (mobile app). |
| 1x | Mismo resultado que GPRS, abre y se puede chatear. | Same result as GPRS, it opens and chatting works. |
| E (EDGE) | Mismo resultado que GPRS y 1x, se puede abrir y chatear. | Same result as GPRS and 1x, it opens and chatting works. |
| Satélite (SOS) | Se puede conectar, pero solo enviar mensajes, no conecta a servidores. | Can connect, but only messages can be sent, it does not connect to servers. |

### Character AI

| Red / Network | 🇪🇸 Español | 🇺🇸 English |
|---|---|---|
| G (GPRS) | La app abrió, el chat abrió y cargaron las imágenes, pero terminó dando error. | The app opened, the chat loaded and images loaded, but it eventually gave an error. |
| E (EDGE) | La app abrió, las imágenes cargan, el chat abre y las respuestas funcionan. | The app opened, images load, the chat opens and responses work. |
| 1x | La app abrió pero no carga nada y termina mostrando un error. | The app opened but nothing loads and it ends with an error. |
| Satélite (SOS) | No abre. | It does not open. |

---

## 📝 Changelog

### v1.6.1
- ✨ New: Independent network type per SIM slot (`-t2` / `--type2`)
- ℹ️ iptables rules only apply to slot 1 — slot 2 is visual only to avoid conflicts

### v1.6.0
- ✨ New: Independent signal level per SIM slot (`-l2` / `--level2`)
- 🐛 Fix: Slot 1 no longer stays stuck with full bars when changing level

### v1.5.9
- ✨ New: NFC icon active by default (can be hidden with `touch nonfc`)

### v1.5.8
- ✨ New: Record mode — clean preset for screenshots/videos
- ✨ New: Network schedule by time of day (`schedule.conf`)

### v1.5.7
- ✨ New: Real-time clock sync (no more frozen clock in demo mode)
- ✨ New: Real-time battery level and charging status sync

### v1.5.6.3
- 🐛 Fix: WiFi icon now correctly hidden on Android 13
- 🐛 Fix: Roaming variable now correctly applied
- 🐛 Fix: Only slot 0 used on Android 13 to avoid demo mode bugs

---

## 👤 Credits / Créditos

- **Mure2005** — original module & Android 13 fix, real-time battery/clock, NFC, record mode, dual slot level, schedule
