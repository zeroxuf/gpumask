#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
APPS_DIR="$HOME/.local/share/applications"

echo "=== gpumask uninstaller ==="

# 1. Search for wrapped applications
wrapped_apps=()
if [[ -d "$APPS_DIR" ]]; then
  shopt -s nullglob
  for f in "$APPS_DIR"/*.desktop; do
    if grep -q "gpumask-run" "$f" 2>/dev/null; then
      wrapped_apps+=("$(basename "$f" .desktop)")
    fi
  done
  shopt -u nullglob
fi

# 2. Prompt user to unwrap apps if found
if [[ ${#wrapped_apps[@]} -gt 0 ]]; then
  echo ""
  echo "Found ${#wrapped_apps[@]} app(s) currently wrapped with gpumask:"
  for app in "${wrapped_apps[@]}"; do
    echo "  - $app"
  done
  echo ""

  # Read from /dev/tty to support running directly via curl | bash
  prompt="y"
  if [[ -r /dev/tty ]]; then
    read -r -p "Do you want to unwrap/restore these apps now? [Y/n]: " prompt </dev/tty || prompt="y"
  fi

  if [[ "$prompt" =~ ^[Yy]$ ]] || [[ -z "$prompt" ]]; then
    echo "Restoring application desktop files..."
    for app in "${wrapped_apps[@]}"; do
      if [[ -x "$BIN_DIR/gpumask" ]]; then
        "$BIN_DIR/gpumask" --undo "$app"
      else
        rm -f "$APPS_DIR/$app.desktop"
        echo "Removed override: $app.desktop"
      fi
    done

    if command -v update-desktop-database >/dev/null 2>&1; then
      update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
    fi
  else
    echo "Skipped restoring apps."
  fi
fi

# 3. Remove binary files and shell completions
echo ""
echo "Removing gpumask binaries from $BIN_DIR ..."
rm -f "$BIN_DIR/gpumask" "$BIN_DIR/gpumask-run"
rm -f "$PREFIX/share/bash-completion/completions/gpumask" 2>/dev/null || true

echo "Uninstallation complete."
