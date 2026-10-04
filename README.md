<div align="center">

# GLADIATOR

**Entorno Linux de escritorio completo dentro de un APK Android.**

Termux embebido + proot-distro + Ubuntu + X11 + escritorio propio + driver GPU real.

</div>

## Que es

Gladiator es un APK Android que empaqueta un entorno Linux completo con escritorio grafico funcional. El usuario abre la app, toca un boton, y tiene una sesion X11 con JWM y un escritorio propio corriendo dentro de un container Ubuntu, con aceleracion grafica real via el driver de la GPU del dispositivo.

No requiere Termux instalado, ni root, ni un servidor X externo. Todo esta adentro del APK.

## Arquitectura

    APK Android (com.glads1)
      |
      +-- Termux embebido (bionic, vive en /data/data/com.glads1/files/usr/)
      |     +-- proot-distro
      |     +-- Termux:X11 (X server, corre como foreground service)
      |     +-- spathad  (daemon Vulkan, host)
      |     +-- scutumd  (daemon GLES, host)
      |
      +-- Container Ubuntu 24.04 (glibc, proot-distro)
            +-- Sesar Desktop Environment (JWM + menu + HUD + wallpaper)
            +-- SuperTuxKart, emuladores, apps GUI
            +-- libEGL.so / libGLESv2.so  (Scutum shim -> socket -> Mali real)
            +-- libspatha-icd.so          (Spatha ICD -> socket -> Mali Vulkan)

Los daemons bionic y el shim glibc hablan por sockets Unix AF_UNIX. El container glibc ve la GPU nativa del dispositivo como si fuera suya, sin emulacion, sin Zink, sin llvmpipe.

## Componentes

**Gladiator** en si mismo es el APK + los scripts de integracion. Todo lo demas vive en repos separados:

| Repo | Descripcion | Licencia |
|---|---|---|
| [Scutum](https://github.com/LexusYTG/Scutum) | Puente GLES/EGL bionic<->glibc. Expone el driver Mali directo. | MIT |
| [Spatha](https://github.com/LexusYTG/Spatha) | Puente Vulkan bionic<->glibc. Expone el driver Mali directo. | MIT |
| [Sesar](https://github.com/LexusYTG/Sesar) | Entorno de escritorio en C puro sobre Xlib + FreeType. | MIT |
| [gladiator-bootstrap](https://github.com/LexusYTG/gladiator-bootstrap) | Bootstrap Termux base + scripts de orquestacion. | GPL-3.0 |
| [gladiator-app](https://github.com/LexusYTG/gladiator-app) | Codigo del APK (Java + assets). | GPL-3.0 |
| [gladiator-init-setup](https://github.com/LexusYTG/gladiator-init-setup) | Scripts de inicializacion y setup. | GPL-3.0 |

Los 3 componentes propios (Scutum, Spatha, Sesar) son MIT. El resto es GPL-3.0 (heredado de Termux y de las partes de la app Android).

## Que incluye

- **Termux base** embebido (bash, apt, proot, proot-distro, etc.)
- **proot-distro** + rootfs Ubuntu 24.04
- **Sesar**: menu de inicio con busqueda, HUD de sistema, wallpaper synthwave, dialogo de energia, tema neon consistente
- **JWM** como window manager (se instala en el primer arranque)
- **XTerm** como terminal
- **Scutum**: acelera GLES 2.0 / 3.0 / 3.1 / 3.2 via el driver Mali directo
- **Spatha**: acelera Vulkan 1.0 / 1.1 / 1.2 via el driver Mali directo
- **gl4es**: traduce OpenGL 1.x / 2.x a GLES

## Requisitos

- **Android 10 o superior recomendado.** Funciona en versiones anteriores pero no probado en todas.
- **GPU Mali-G52 MC2** (probado). Otros GPUs sin probar.
- ~3 GB de almacenamiento libre.
- Conexion a internet en el primer arranque (descarga ~200 MB de paquetes Ubuntu).

## Instalacion

1. Descargar `gladiator-1.0-beta.apk` del [release](https://github.com/LexusYTG/gladiator/releases/latest).
2. Instalar en el celular (permitir origenes desconocidos si hace falta).
3. Abrir, leer y aceptar las advertencias.
4. Tocar el boton + para crear un contenedor.
5. Esperar el primer arranque (puede tardar hasta 10 minutos).

El primer arranque descarga JWM, XTerm, fuentes y dependencias desde los repos de Ubuntu. Despues de eso, los arranques son instantaneos.

## Advertencias

**Proyecto experimental. Version 1.0 beta.**

- Solo probado en **Mali-G52 MC2** con driver ARM propietario. Otros GPUs pueden o no funcionar.
- Los componentes (Scutum, Spatha, Sesar) estan en desarrollo activo.
- El rendimiento puede no estar asegurado. Depende del dispositivo, la pista y los shaders de cada app.
- Bugs visuales conocidos en superficies complejas.
- El primer arranque puede tardar hasta 10 minutos. La pantalla de carga muestra un cronometro con color: verde (<5min) = normal, naranja (5-10min) = tardando, rojo (>10min) = probablemente se colgo.

## Estado del proyecto

**Funcional.** SuperTuxKart corre con geometria completa, karts, HUD y minimapa. vkcube y vkcubepp corren sobre Spatha. Sesar Desktop Environment provee menu, HUD, wallpaper y dialogo de energia.

**Pendiente:**
- Optimizacion de rendimiento en el present de Scutum (round-trips por frame, MIT-SHM, present asincrono).
- Compatibilidad con otros GPUs (Adreno, otros Mali, PowerVR).

## Como se construye

    cd ~/dev/gladiator
    export PATH=$HOME/android-sdk/gradle/gradle-8.14.5/bin:$PATH
    gradle :app:zipBootstrap --rerun-tasks --console=plain
    gradle :app:assembleDebug --console=plain

El APK se genera en `app/build/outputs/apk/debug/app-debug.apk`.

El task `zipBootstrap` empaqueta el bootstrap (submodulo `bootstrap/` + share/spatha + share/sesar) en `app/src/main/assets/bootstrap-aarch64.zip`, que se embebe en el APK.

## Licencia

**GPL-3.0** para Gladiator, gladiator-bootstrap, gladiator-app e gladiator-init-setup. Ver LICENSE.

Los submodulos Scutum, Spatha y Sesar son **MIT**. Ver sus respectivos repos.

Termux base viene con sus propias licencias (mayormente GPL-3.0). Ver `bootstrap/share/LICENSES/` para el listado completo.

GL4ES es MIT (Sebastien Chevalier). Ver `bootstrap/share/LICENSES/ATTRIBUTION.txt`.

## Creditos

- Termux y Termux:X11 por la base de la infraestructura Android/glibc.
- Sebastien Chevalier por gl4es.
- Todos los componentes propios (Scutum, Spatha, Sesar, Gladiator) fueron desarrollados por LexusYTG.
