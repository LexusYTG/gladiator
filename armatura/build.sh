#!/data/data/com.termux/files/usr/bin/bash
# build.sh — Compila los componentes nativos de Gladiator.
#
# Uso:
#   ./build.sh              compila todo
#   ./build.sh scutum       solo Scutum
#   ./build.sh spatha       solo Spatha
#   ./build.sh lorica       solo Lorica
#   ./build.sh --clean all  rebuild completo (borra build/)
#
# Artefactos:
#   armatura/Scutum/build/{glibc,bionic}/
#   armatura/Spatha/build/{glibc,bionic}/
#   armatura/Lorica/build/

set +e

GLAD="${GLAD:-$HOME/dev/gladiator}"
SCUT="$GLAD/armatura/Scutum"
SPA="$GLAD/armatura/Spatha"
LOR="$GLAD/armatura/Lorica"
TC=/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs
PD=/data/data/com.termux/files/usr/bin/proot-distro

CLEAN=0
if [ "$1" = "--clean" ]; then CLEAN=1; shift; fi
TARGET="${1:-all}"

log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m   OK\033[0m\n'; }
fail() { printf '\n\033[1;31m!! %s\033[0m\n' "$*" >&2; }

build_scutum() {
    mkdir -p "$SCUT/build/glibc" "$SCUT/build/bionic"

    log "Scutum glibc"
    rm -rf "$TC/root/Scutum"
    mkdir -p "$TC/root/Scutum"
    cp -f "$SCUT/glibc"/*.c "$SCUT/glibc"/*.h "$TC/root/Scutum/" 2>/dev/null
    $PD login ubuntu -- /bin/bash -c '
        cd /root/Scutum
        gcc -O2 -Wall -fPIC -shared -pthread \
            -o libEGL.so sc_egl.c sc_gles.c sc_core.c \
            -ldl -lpthread -lxcb -lxcb-shm || exit 1
        cp -f libEGL.so libGLESv2.so
    ' || { fail "Scutum glibc"; return 1; }
    cp -f "$TC/root/Scutum/libEGL.so"    "$SCUT/build/glibc/libEGL.so"
    cp -f "$TC/root/Scutum/libGLESv2.so" "$SCUT/build/glibc/libGLESv2.so"
    ok

    log "Scutum bionic"
    ( cd "$SCUT/bionic" && \
      clang -O2 -Wall -pthread -I../glibc \
        -o ../build/bionic/scutumd scutumd.c -ldl ) \
      || { fail "Scutum bionic"; return 1; }
    ok
}

build_spatha() {
    mkdir -p "$SPA/build/glibc" "$SPA/build/bionic"

    log "Spatha glibc"
    rm -rf "$TC/root/Spatha"
    mkdir -p "$TC/root/Spatha"
    cp -f "$SPA/glibc"/*.c "$SPA/glibc"/*.inc "$TC/root/Spatha/" 2>/dev/null
    cp -f "$SPA/proto.c" "$SPA/proto.h" "$SPA/chain.h" "$SPA/wire.h" "$TC/root/Spatha/"
    $PD login ubuntu -- /bin/bash -c '
        cd /root/Spatha
        gcc -O2 -Wall -fPIC -shared -fvisibility=hidden -pthread \
            -o libspatha-icd.so libspatha-icd.c proto.c -ldl || exit 1
    ' || { fail "Spatha glibc"; return 1; }
    cp -f "$TC/root/Spatha/libspatha-icd.so" "$SPA/build/glibc/libspatha-icd.so"
    ok

    log "Spatha bionic"
    ( cd "$SPA/bionic" && \
      clang -O2 -Wall -pthread -I.. \
        -o ../build/bionic/spathad spathad.c ../proto.c -ldl ) \
      || { fail "Spatha bionic"; return 1; }
    ok
}

build_lorica() {
    mkdir -p "$LOR/build"

    log "Lorica"

    if [ "$CLEAN" = "1" ] || [ ! -f "$TC/root/Lorica/build/CMakeCache.txt" ]; then
        rm -rf "$TC/root/Lorica"
        cp -r "$LOR" "$TC/root/Lorica"
        rm -rf "$TC/root/Lorica/.git" "$TC/root/Lorica/build"
    else
        # sync fuentes sin tocar build/ (preserva objetos compilados)
        cp -ru "$LOR/src"     "$TC/root/Lorica/" 2>/dev/null
        cp -ru "$LOR/include" "$TC/root/Lorica/" 2>/dev/null
        cp -u  "$LOR/CMakeLists.txt"     "$TC/root/Lorica/CMakeLists.txt" 2>/dev/null
        cp -u  "$LOR/src/CMakeLists.txt" "$TC/root/Lorica/src/CMakeLists.txt" 2>/dev/null
    fi

    $PD login ubuntu -- /bin/bash -c '
        cd /root/Lorica
        if [ ! -d build ]; then
            mkdir build && cd build
            cmake .. -DCMAKE_BUILD_TYPE=Release \
                -DNOX11=OFF -DNOEGL=OFF \
                -DSTATICLIB=OFF -DGBM=OFF >/dev/null || exit 1
        else
            cd build
        fi
        make -j4 || exit 1
    ' || { fail "Lorica"; return 1; }
    cp -f "$TC/root/Lorica/lib/libGL.so.1" "$LOR/build/libGL.so.1"
    ok
}

case "$TARGET" in
    scutum) build_scutum ;;
    spatha) build_spatha ;;
    lorica) build_lorica ;;
    all)    build_scutum && build_spatha && build_lorica ;;
    *)      echo "Uso: $0 [--clean] [all|scutum|spatha|lorica]" >&2; exit 1 ;;
esac

log "Artefactos"
for f in \
    "$SCUT/build/glibc/libEGL.so" \
    "$SCUT/build/glibc/libGLESv2.so" \
    "$SCUT/build/bionic/scutumd" \
    "$SPA/build/glibc/libspatha-icd.so" \
    "$SPA/build/bionic/spathad" \
    "$LOR/build/libGL.so.1"
do
    if [ -f "$f" ]; then
        ls -la "$f"
    else
        fail "falta: $f"
    fi
done
