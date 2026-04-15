#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUND="$SCRIPT_DIR/moan.wav"
SLEEP_SCRIPT="$HOME/.sleep"

echo "==> Generating moan sound..."
python3 "$SCRIPT_DIR/generate_moan.py"

echo "==> Checking sleepwatcher..."
if ! command -v sleepwatcher &>/dev/null; then
    echo "    Installing sleepwatcher via Homebrew..."
    brew install sleepwatcher
else
    echo "    sleepwatcher already installed."
fi

echo "==> Writing $SLEEP_SCRIPT..."
cat > "$SLEEP_SCRIPT" <<EOF
#!/bin/bash
afplay "$SOUND"
EOF
chmod +x "$SLEEP_SCRIPT"

echo "==> Starting sleepwatcher service..."
brew services restart sleepwatcher

echo ""
echo "Done. Close your laptop lid and enjoy."
echo "To uninstall: brew services stop sleepwatcher && rm $SLEEP_SCRIPT"
