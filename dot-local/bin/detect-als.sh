#!/usr/bin/env bash
# Detect ambient light sensor on ThinkPad — run with: sudo ./detect-als.sh
set -euo pipefail

echo "=== ThinkPad model ==="
cat /sys/class/dmi/id/product_name 2>/dev/null || echo "unknown"
cat /sys/class/dmi/id/product_family 2>/dev/null || echo "unknown"

echo ""
echo "=== ACPI ALS device (ACPI0008) ==="
for d in /sys/bus/acpi/devices/*/; do
  hid="$(cat "$d/hid" 2>/dev/null)" || continue
  [[ "$hid" == "ACPI0008" ]] && echo "FOUND: $d (hid=$hid)"
done
echo "(empty = no ACPI ALS exposed)"

echo ""
echo "=== Intel Sensor Hub (ISH) ==="
lsmod | grep -iE 'intel_ish|ishtp|hid_sensor' || echo "No ISH modules loaded"

echo ""
echo "=== Loading ALS kernel modules ==="
for mod in acpi-als hid-sensor-als; do
  echo -n "  $mod: "
  if modprobe "$mod" 2>/dev/null; then
    echo "loaded OK"
  else
    echo "failed (not a problem if hardware isn't present)"
  fi
done

echo ""
echo "=== IIO devices after module load ==="
if [ -d /sys/bus/iio/devices ]; then
  for d in /sys/bus/iio/devices/iio:device*; do
    [ -d "$d" ] || continue
    name="$(cat "$d/name" 2>/dev/null || echo "unknown")"
    illum="$(ls "$d"/in_illuminance* 2>/dev/null | head -3 || true)"
    echo "  $d: name=$name"
    [ -n "$illum" ] && echo "    illuminance files: $illum"
    # Try to read a value
    for f in "$d"/in_illuminance_raw "$d"/in_illuminance_input; do
      [ -f "$f" ] && echo "    $(basename "$f") = $(cat "$f" 2>/dev/null || echo "N/A")"
    done
  done
fi
[ -z "$(ls /sys/bus/iio/devices/iio:device* 2>/dev/null)" ] && echo "  (none found)"

echo ""
echo "=== HID sensor devices ==="
find /sys/devices -path "*/HID-SENSOR*" -name "name" \
  -exec sh -c 'echo "  $(dirname {}): $(cat {})"' \; 2>/dev/null | head -10
echo "(empty = no HID sensors)"

echo ""
echo "=== I2C buses (for manual ALS chip detection) ==="
i2cdetect -l 2>/dev/null | head -15 || echo "i2cdetect not available"

echo ""
echo "=== Webcam devices (fallback ALS via webcam) ==="
ls -1 /dev/video* 2>/dev/null || echo "  (none)"

echo ""
echo "=== Summary ==="
if ls /sys/bus/iio/devices/iio:device*/in_illuminance* >/dev/null 2>&1; then
  echo "✅ IIO ALS detected — wluma can use [als.iio]"
elif ls /dev/video* >/dev/null 2>&1; then
  echo "⚠️  No hardware ALS found, but webcam available — wluma can use [als.webcam]"
else
  echo "❌ No ALS and no webcam — wluma can use [als.time] (time-of-day simulation)"
fi
