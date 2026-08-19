#!/usr/bin/env bash

# if anything goes wrong, stop
set -euo pipefail

DGPU_PCI=""

# Searching for gpu
for dev in /sys/bus/pci/devices/*; do
if [[ -r "$dev/vendor" ]] && [[ "$(<"$dev/vendor")" == "0x10de" ]]; then
    DGPU_PCI="${dev$$*/}"
    break 
  fi
done

# Check if bwrap exist
if ! command -v bwrap >/dev/null 2>&1; then
  echo "gpumask: error: 'bwrap' is not installed. Run install.sh or install bubblewrap first." >&2
  exit 1
fi

BWRAP_ARGS=(
  --bind / /
  --dev /dev
  --dev-bind /dev/dri /dev/dri
  --tmpfs /dev/shm
)
