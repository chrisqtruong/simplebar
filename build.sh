#!/bin/bash
# Builds SimpleBar.app next to this script. Needs Xcode Command Line Tools:
#   xcode-select --install
set -euo pipefail
cd "$(dirname "$0")"

APP="SimpleBar.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# Universal binary: runs on Apple Silicon and Intel Macs.
BUILD="$(mktemp -d)"
swiftc -O -target arm64-apple-macos13.0  main.swift -o "$BUILD/SimpleBar-arm64"
swiftc -O -target x86_64-apple-macos13.0 main.swift -o "$BUILD/SimpleBar-x86_64"
lipo -create "$BUILD/SimpleBar-arm64" "$BUILD/SimpleBar-x86_64" -output "$APP/Contents/MacOS/SimpleBar"
rm -rf "$BUILD"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>SimpleBar</string>
    <key>CFBundleDisplayName</key><string>SimpleBar</string>
    <key>CFBundleIdentifier</key><string>com.local.simplebar</string>
    <key>CFBundleExecutable</key><string>SimpleBar</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built $(pwd)/$APP"
echo "Install:  mv $APP /Applications/ && open /Applications/$APP"
