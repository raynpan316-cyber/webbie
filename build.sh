#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
root="$PWD"
build="$root/build"
sdk="${WEBBIE_SDK_PATH:-$(xcrun --sdk macosx --show-sdk-path)}"
mkdir -p "$build/module-cache"
stage="$(mktemp -d "$build/.stage.XXXXXX")"
trap 'rm -rf "$stage"' EXIT
app="$stage/Webbie.app"
resources="$app/Contents/Resources"
mkdir -p "$app/Contents/MacOS" "$resources"

xcrun swiftc -sdk "$sdk" -O -target arm64-apple-macosx14.0 \
    -module-cache-path "$build/module-cache" \
    -Xcc "-fmodules-cache-path=$build/module-cache" \
    Sources/Localization.swift Sources/Media.swift Sources/Workbench.swift Sources/Interface.swift \
    -o "$app/Contents/MacOS/MaterialWorkbench"
cp Sources/Info.plist "$app/Contents/"
cp Sources/Webbie.png Sources/Workbench.icns LICENSE "$resources/"
for language in zh-Hans en ja; do
    cp -R "Sources/Localizations/$language.lproj" "$resources/"
done

codesign --force --sign - "$app"
codesign --verify --deep --strict "$app"
rm -rf "$build/Webbie.app"
mv "$app" "$build/Webbie.app"
printf '%s\n' "$build/Webbie.app"
