#!/bin/bash
set -euo pipefail

if [[ $# != 2 ]]; then
    printf 'Usage: %s <source-archives> <runtime-directory>\n' "$0" >&2
    exit 2
fi

archives="$(cd "$1" && pwd)"
mkdir -p "$2"
output="$(cd "$2" && pwd)"
jobs="${WEBBIE_BUILD_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '4')}"
export SDKROOT="${WEBBIE_SDK_PATH:-$(xcrun --sdk macosx --show-sdk-path)}"
export MACOSX_DEPLOYMENT_TARGET=14.0
export CC="$(xcrun --find clang)"

cd "$archives"
shasum -a 256 -c <<'CHECKSUMS'
7138d28c96d9d3e3af4ee3d8cad72741f8ffb40da90c1112235dea3ecd3178a3  ffmpeg-8.1.3.tar.xz
3df5124d5ad3a98312ffd7ba6a9b36230e4f8a3e66d3ce0f425e336c32d216eb  lame-4.0.tar.gz
6eeb82934e69fd51e043bd8c5b0d152839638d1ce7aa4eea65a3fedcf83ff224  x264-b35605a.tar.bz2
d0cd841bc8e55b9da888106c00dc256d05b7d1d8e5a46f4be4eb4c5125bd2dc4  pkgconf-3.0.11.tar.xz
CHECKSUMS

scratch="$(mktemp -d "${TMPDIR:-/tmp}/webbie-ffmpeg.XXXXXX")"
trap 'rm -rf "$scratch"' EXIT
prefix="$scratch/installed"
for archive in ffmpeg-8.1.3.tar.xz lame-4.0.tar.gz x264-b35605a.tar.bz2 pkgconf-3.0.11.tar.xz; do
    tar -xf "$archives/$archive" -C "$scratch"
done

(
    cd "$scratch/pkgconf-3.0.11"
    ./configure --prefix="$prefix" --enable-static --disable-shared
    make -j"$jobs" install
)
export PKG_CONFIG="$prefix/bin/pkgconf"
(
    cd "$scratch/lame-4.0"
    ./configure --prefix="$prefix" --enable-static --disable-shared --disable-frontend --disable-decoder
    make -j"$jobs" install
)
x264="$scratch/x264-b35605ace3ddf7c1a5d67a2eb553f034aef41d55"
(
    cd "$x264"
    ./configure --prefix="$prefix" --enable-static --disable-cli --disable-opencl
    make -j"$jobs" install
)

ffmpeg="$scratch/ffmpeg-8.1.3"
(
    cd "$ffmpeg"
    export PKG_CONFIG_LIBDIR="$prefix/lib/pkgconfig"
    export PKG_CONFIG_PATH=
    ./configure --prefix="$prefix" --arch=arm64 --target-os=darwin --cc="$CC" --sysroot="$SDKROOT" \
        --enable-gpl --enable-libx264 --enable-libmp3lame --enable-securetransport \
        --enable-static --disable-shared --disable-autodetect --disable-ffplay --disable-doc --disable-debug \
        --pkg-config="$prefix/bin/pkgconf" --pkg-config-flags=--static \
        --extra-cflags="-I$prefix/include -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET" \
        --extra-ldflags="-L$prefix/lib -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
    make -j"$jobs" ffmpeg ffprobe
)

mkdir -p "$output/Licenses/FFmpeg" "$output/Licenses/x264" "$output/Licenses/LAME"
install -m 755 "$ffmpeg/ffmpeg" "$ffmpeg/ffprobe" "$output/"
cp "$ffmpeg/COPYING.GPLv2" "$ffmpeg/COPYING.LGPLv2.1" "$ffmpeg/LICENSE.md" "$output/Licenses/FFmpeg/"
cp "$x264/COPYING" "$output/Licenses/x264/"
cp "$scratch/lame-4.0/COPYING" "$scratch/lame-4.0/LICENSE" "$output/Licenses/LAME/"
"$output/ffmpeg" -hide_banner -buildconf > "$output/Licenses/FFmpeg/build-configuration.txt" 2>&1
