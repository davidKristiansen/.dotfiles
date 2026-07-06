#!/usr/bin/env bash
# Load the Intel Sensor Hub (ISH) module chain to expose the ALS.
# Run with: sudo ./probe-ish-als.sh
set -euo pipefail

echo "=== Loading Intel ISH module chain ==="
for mod in intel_ish_ipc intel_ishtp intel_ishtp_hid hid_sensor_hub hid_sensor_als; do
  printf "  %-24s" "$mod:"
  if lsmod | grep -qw "$mod" 2>/dev/null; then
    echo "already loaded"
  elif modprobe "$mod" 2>/dev/null; then
    echo "loaded OK"
  else
    echo "failed"
  fi
done

# Give udev a moment to create devices
sleep 1

echo ""
echo "=== ISH modules now loaded ==="
lsmod | grep -iE 'intel_ish|ishtp|hid_sensor' || echo "  (none)"

echo ""
echo "=== IIO devices ==="
found=0
for d in /sys/bus/iio/devices/iio:device*; do
  [ -d "$d" ] || continue
  found=1
  name="$(cat "$d/name" 2>/dev/null || echo "unknown")"
  echo "  $d: $name"
  for f in "$d"/in_illuminance_raw "$d"/in_illuminance_input; do
    [ -f "$f" ] && echo "    $(basename "$f") = $(cat "$f" 2>/dev/null || echo "N/A")"
  done
done
(( found )) || echo "  (none)"

echo ""
echo "=== HID sensor devices ==="
find /sys/devices -path "*/HID-SENSOR*" -name "name" \
  -exec sh -c 'echo "  $(dirname {}): $(cat {})"' \; 2>/dev/null | head -10
echo "(empty = none)"

echo ""
echo "=== ACPI check for ISH ==="
for d in /sys/bus/acpi/devices/*/; do
  hid="$(cat "$d/hid" 2>/dev/null)" || continue
  case "$hid" in
    INTC10*|INTC11*|INT33D5|ACPI0008) echo "  $d  hid=$hid" ;;
  esac
done
echo "(empty = no ISH/ALS ACPI device)"

echo ""
if ls /sys/bus/iio/devices/iio:device*/in_illuminance* >/dev/null 2>&1; then
  echo "✅ ALS detected! wluma can use [als.iio]"
  echo ""
  echo "To persist the modules across reboots, run:"
  echo "  echo -e 'intel_ish_ipc\nintel_ishtp\nintel_ishtp_hid\nhid_sensor_hub\nhid_sensor_als' | sudo tee /etc/modules-load.d/thinkpad-als.conf"
else
  echo "❌ No ALS found even after loading ISH stack."
  echo "   This SKU may not have the sensor, or it may be disabled in BIOS."
  echo "   Check BIOS → Config → Power → Adaptive Brightness (if the option exists)."
  echo ""
  echo "   Fallback: wluma can use [als.webcam] with your /dev/video* devices."
fi
