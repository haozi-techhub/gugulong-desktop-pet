#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
APP="$ROOT/build/咕咕龙.app"
rm -f "$ROOT/build/Gugulong" "$APP/Contents/MacOS/Gugulong"
clang -fobjc-arc -O2 -framework Cocoa "$ROOT/Sources/main.m" -o "$ROOT/build/Gugulong"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT/build/Gugulong" "$APP/Contents/MacOS/Gugulong"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/../outputs/gugulong-pet/spritesheet.webp" "$APP/Contents/Resources/spritesheet.webp"
cp "$ROOT/Assets/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
cp "$ROOT/Assets/MenuBarIconTemplate.png" "$APP/Contents/Resources/MenuBarIconTemplate.png"
cp "$ROOT/Assets/MenuBarIconTemplate@2x.png" "$APP/Contents/Resources/MenuBarIconTemplate@2x.png"
codesign --force --deep --sign - "$APP"
echo "已生成：$APP"
