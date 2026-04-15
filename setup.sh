#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUND="$SCRIPT_DIR/moan.wav"
WAKEUP_SCRIPT="$HOME/.wakeup"
MOUNT_PLIST="$HOME/Library/LaunchAgents/com.tasos.moan-on-mount.plist"

echo "==> Generating moan sound..."
python3 "$SCRIPT_DIR/generate_moan.py"

echo "==> Checking sleepwatcher..."
if ! command -v sleepwatcher &>/dev/null; then
    echo "    Installing sleepwatcher via Homebrew..."
    brew install sleepwatcher
else
    echo "    sleepwatcher already installed."
fi

echo "==> Writing $WAKEUP_SCRIPT..."
cat > "$WAKEUP_SCRIPT" <<EOF
#!/bin/bash
afplay "$SOUND"
EOF
chmod +x "$WAKEUP_SCRIPT"

echo "==> Starting sleepwatcher service..."
brew services restart sleepwatcher

echo "==> Installing USB mount LaunchAgent..."
cat > "$MOUNT_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.tasos.moan-on-mount</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/afplay</string>
        <string>$SOUND</string>
    </array>
    <key>StartOnMount</key>
    <true/>
</dict>
</plist>
EOF
launchctl unload "$MOUNT_PLIST" 2>/dev/null || true
launchctl load "$MOUNT_PLIST"

echo ""
echo "Done. Moans on: lid open, USB/disk mount."
echo "To uninstall:"
echo "  brew services stop sleepwatcher && rm $WAKEUP_SCRIPT"
echo "  launchctl unload $MOUNT_PLIST && rm $MOUNT_PLIST"
