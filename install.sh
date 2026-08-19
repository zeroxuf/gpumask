#!/usr/bin/env bash
# Quick installer for gpumask (non-Arch)
#
# Installs to ~/.local/bin by default. Override with PREFIX=usr/local
# (then run with sudo) if you want a system-wide instaed.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/zeroxuf/gpumask/main"
PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"

mkdir -p "$BIN_DIR"

echo "Installing gpumask to $BIN_DIR ..."
curl -fsSL "$REPO_RAW/bin/gpumask" -o "$BIN_DIR/gpumask"
curl -fsSL "$REPO_RAW/bin/gpumask-run" -o "$BIN_DIR/gpumask-run"
chmod +x "$BIN_DIR/gpumask" "$BIN_DIR/gpumask-run"

if ! command -v bwrap >/dev/null 2>&1; then
  echo ""
  echo "Warning: bubblewrap (bwrap) is not installed - 'gpumask --apply' needs it." >&2
  echo "Install it with your package manager, e.g.: sudo pacman -S bubblewrap" >&2
  echo "                                        or: sudo apt install bubblewrap" >&2
fi

case ":$PATH:" in
*":$BIN_DIR:"*)
  ;;
*)
  echo ""
  echo "Note: $BIN_DIR is not on your PATH. Add it in your shell config:"
  echo "  fish:       set -Ux fish_user_paths $BIN_DIR \$fish_user_paths"
  echo "  bash/zsh:   export PATH=\"$BIN_DIR:\$PATH\""
  ;;
esac

echo ""
echo "Installed. Try: gpumask --help"
