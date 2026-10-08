<div align="center">

# GLADIATOR

**A full Linux desktop inside an Android app.**

Embedded Termux + Ubuntu + X11 + its own desktop + your phone's real GPU.

</div>

---

## What it is

Gladiator is an Android app (APK) that packs a complete Linux desktop environment. Open the app, tap a button, and you get a desktop session running inside an Ubuntu container, with graphics accelerated by your device's own GPU.

No separate Termux install, no root, no external X server. Everything is inside the APK.

## How it's put together

```
Android app (com.glads1)
│
├── Embedded Termux (Android side)
│     ├── proot-distro      runs the Linux container
│     ├── Termux:X11        the display server
│     ├── spathad           Vulkan bridge (host half)
│     └── scutumd           OpenGL ES bridge (host half)
│
└── Ubuntu 24.04 container (Linux side)
      ├── Sesar desktop     menu, HUD, wallpaper, taskbar
      ├── Apps              SuperTuxKart, emulators, GUI programs
      ├── libEGL / libGLESv2     Scutum  →  real GPU
      └── libspatha-icd.so       Spatha  →  real GPU (Vulkan)
```

The Android-side daemons and the container-side libraries talk over local sockets. The container sees the phone's GPU as if it were its own. No Zink, no software rendering.

## What's inside

- **Embedded Termux** and **proot-distro** with an **Ubuntu 24.04** container
- **Sesar**, the desktop: start menu with search, system HUD, synthwave wallpaper, power dialog, consistent neon theme
- **JWM** window manager and **XTerm** terminal (installed on first launch)
- **Scutum**, which accelerates OpenGL ES 2.0 / 3.0 / 3.1 / 3.2
- **Spatha**, which accelerates Vulkan 1.0 / 1.1 / 1.2
- **gl4es**, which translates classic OpenGL 1.x / 2.x into OpenGL ES

## Requirements

- Android 10 or newer recommended (older versions may work but aren't fully tested)
- A **Mali-G52 MC2** GPU (the only one tested so far)
- About 3 GB of free storage
- Internet on first launch (around 200 MB of Ubuntu packages)

## Installation

1. Download `gladiator-1.0-beta.apk` from the [latest release](https://github.com/LexusYTG/gladiator/releases/latest).
2. Install it on your phone (allow unknown sources if asked).
3. Open the app and accept the warnings.
4. Tap **+** to create a container.
5. Wait for the first launch. It can take up to 10 minutes.

The first launch downloads JWM, XTerm, fonts and other dependencies. After that, starting up is instant.

The loading screen shows a timer: **green** (under 5 min) is normal, **orange** (5–10 min) is slow, **red** (over 10 min) probably means it got stuck.

## ⚠️ Heads up

**Experimental. Version 1.0 beta.**

- Only tested on a **Mali-G52 MC2**. Other GPUs may or may not work.
- Scutum, Spatha and Sesar are under active development.
- Performance isn't guaranteed. It depends on your device and on each app's workload.
- Some visual glitches remain on complex scenes.

## Where things stand

**Working:** SuperTuxKart runs with full geometry, karts, HUD and minimap. `vkcube` and `vkcubepp` run on Spatha. The Sesar desktop provides its menu, HUD, wallpaper and power dialog.

**Still to do:**
- Faster frame presenting in Scutum (fewer round-trips per frame, shared memory, asynchronous presenting)
- Support for other GPUs (Adreno, other Mali models, PowerVR)

## Repository layout

```
gladiator/
├── app/                        Android app (gladiator-app)
├── boot/
│   ├── gladiator-bootstrap/    Termux base + proot + Sesar
│   └── init-setup/             first-run scripts
├── embedded/                   Termux forks (X11, terminal, shared)
└── armatura/
    ├── Scutum/                 OpenGL ES bridge
    ├── Spatha/                 Vulkan bridge
    ├── Sesar/                  desktop environment
    └── Orator/                 audio bridge (PulseAudio → Android)
```

## Components

Gladiator itself is the APK plus its integration scripts. Everything else lives in its own repository:

| Repo | What it is |
|---|---|---|
| [Scutum](https://github.com/LexusYTG/Scutum) | OpenGL ES bridge to the device GPU |
| [Spatha](https://github.com/LexusYTG/Spatha) | Vulkan bridge to the device GPU |
| [Sesar](https://github.com/LexusYTG/Sesar) | Desktop environment in plain C |
| [gladiator-bootstrap](https://github.com/LexusYTG/gladiator-bootstrap) | Termux base + orchestration scripts |
| [gladiator-app](https://github.com/LexusYTG/gladiator-app) | The APK (Java + assets) |
| [gladiator-init-setup](https://github.com/LexusYTG/gladiator-init-setup) | First-run setup scripts |

## Building

```sh
cd ~/dev/gladiator
export PATH=$HOME/android-sdk/gradle/gradle-8.14.5/bin:$PATH

gradle :app:zipBootstrap --rerun-tasks --console=plain
gradle :app:assembleDebug --console=plain
```

The APK appears at `app/build/outputs/apk/debug/app-debug.apk`.

`zipBootstrap` bundles the bootstrap (plus Spatha and Sesar files) into `app/src/main/assets/bootstrap-aarch64.zip`, which is embedded in the APK.

## Legal

License texts and attributions for every component are in `boot/gladiator-bootstrap/share/LICENSES/`. Start with `ATTRIBUTION.txt`.

## Credits

- **Termux** and **Termux:X11** for the Android/Linux foundation.
- **Sebastien Chevalier** for gl4es.
- Scutum, Spatha, Sesar and Gladiator were created by **LexusYTG**.
