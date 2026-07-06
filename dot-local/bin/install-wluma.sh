#!/usr/bin/env bash
# Build and install wluma from source on Ubuntu.
# Run with: bash install-wluma.sh
set -euo pipefail

echo "=== Installing build dependencies ==="
sudo apt-get update -qq
sudo apt-get install -y v4l-utils libv4l-dev libudev-dev libvulkan-dev libdbus-1-dev

echo ""
echo "=== Cloning wluma ==="
WLUMA_DIR="${HOME}/src/wluma"
if [ -d "$WLUMA_DIR" ]; then
  echo "Directory exists, pulling latest..."
  git -C "$WLUMA_DIR" pull
else
  mkdir -p "$(dirname "$WLUMA_DIR")"
  git clone https://github.com/maximbaz/wluma.git "$WLUMA_DIR"
fi

echo ""
echo "=== Building wluma (release) ==="
cd "$WLUMA_DIR"
cargo build --locked --release

echo ""
echo "=== Installing binary ==="
install -Dm755 target/release/wluma "${HOME}/.local/bin/wluma"

echo ""
echo "=== Installing udev rules (for direct backlight access) ==="
if [ -f 90-wluma-backlight.rules ]; then
  sudo install -Dm644 90-wluma-backlight.rules /etc/udev/rules.d/90-wluma-backlight.rules
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  echo "  Installed. You may need to log out/in for group changes to take effect."
fi

echo ""
echo "=== Installing systemd user service (optional) ==="
mkdir -p "${HOME}/.config/systemd/user"
if [ -f wluma.service ]; then
  cp wluma.service "${HOME}/.config/systemd/user/"
  echo "  Service installed. Enable with: systemctl --user enable --now wluma"
  echo "  (But the waybar toggle handles start/stop, so you may not need this.)"
fi

echo ""
echo "✅ wluma installed to ~/.local/bin/wluma"
echo ""
echo "Next steps:"
echo "  1. Verify output names:  swaymsg -t get_outputs"
echo "  2. Edit config if needed: \$EDITOR ~/.config/wluma/config.toml"
echo "  3. Test manually:         wluma"
echo "  4. Reload waybar:         pkill waybar && waybar &"
echo "  5. Click the 󰃠 icon next to backlight to toggle auto mode"
