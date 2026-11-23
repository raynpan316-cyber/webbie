#!/bin/bash
set -euo pipefail

if [[ $# != 2 ]]; then
    printf 'Usage: %s <downloaded-inputs> <runtime-directory>\n' "$0" >&2
    exit 2
fi

inputs="$(cd "$1" && pwd)"
runtime="$(cd "$2" && pwd)"
script_dir="$(cd "$(dirname "$0")" && pwd)"
test -x "$runtime/ffmpeg"
test -x "$runtime/ffprobe"
test ! -e "$runtime/python"
test -d "$inputs/notices"

cd "$inputs"
shasum -a 256 -c <<'CHECKSUMS'
7a2384641584ab9984221fcb0fc9265df465922af71be71410529e2a9c3f0540  python-3.13.18-arm64.tar.gz
e51e69e89489f199530f13d32a4342da3ddb2cf34842f364603a066db05afbf3  yt-dlp
9f0bf660393da2eaff044cdc7444cb08c73f235849b61d224d825a194ce7c98e  deno-aarch64-apple-darwin.zip
42d35340cc5b9ba78e818ddbff0c5b1c2b779de448a340fd1b989f5fa8670e1b  certifi-2026.10.19-py3-none-any.whl
19ee6127ee34de7d83ce3d371ebc5ed91addbdcc39f9ab15ce4eb35a4e534971  cffi-2.1.1-cp313-cp313-macosx_11_0_arm64.whl
88cb5e34eb23eb2106711b06df68027209c72be709df239c6029345551e0acfd  curl_cffi-0.17.0-cp310-abi3-macosx_11_0_arm64.whl
e5c6e8d3fbad53479cab09ac03729e0a9faf2bee3db8208a550daf5af81a5934  pycparser-2.23-py3-none-any.whl
CHECKSUMS

tar -xf "$inputs/python-3.13.18-arm64.tar.gz" -C "$runtime"
unzip -q "$inputs/deno-aarch64-apple-darwin.zip" deno -d "$runtime"
install -m 644 "$inputs/yt-dlp" "$runtime/yt-dlp.pyz"
install -m 755 "$script_dir/yt-dlp" "$runtime/yt-dlp"
ditto "$inputs/notices" "$runtime/Licenses"
"$runtime/python/bin/python3" -I -B -m pip --disable-pip-version-check --no-cache-dir install \
    --no-index --no-deps --no-compile \
    "$inputs/certifi-2026.10.19-py3-none-any.whl" \
    "$inputs/cffi-2.1.1-cp313-cp313-macosx_11_0_arm64.whl" \
    "$inputs/curl_cffi-0.17.0-cp310-abi3-macosx_11_0_arm64.whl" \
    "$inputs/pycparser-2.23-py3-none-any.whl"
"$runtime/yt-dlp" --version
"$runtime/deno" --version
