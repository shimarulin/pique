#!/usr/bin/env bash
set -euo pipefail

# pique installer
# Installs to ~/.config/pique
# Creates launcher symlink in ~/.local/bin

INSTALL_DIR="${PIQUE_INSTALL_DIR:-$HOME/.config/pique}"
BIN_DIR="${HOME}/.local/bin"
COMMAND_NAME="pique"

echo "=== pique installer ==="
echo ""

# --- Check dependencies ---

for cmd in git mise; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is required but not found." >&2
        exit 1
    fi
done

# --- Determine source ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/mise.toml" ] && [ -d "$SCRIPT_DIR/profiles" ]; then
    SOURCE_DIR="$SCRIPT_DIR"
    echo "Installing from: $SOURCE_DIR"
else
    REPO_URL="${1:?Specify repository URL or run from within the repository}"
    SOURCE_DIR=""
fi

# --- Install or update ---

if [ -n "$SOURCE_DIR" ]; then
    if [ "$SOURCE_DIR" = "$INSTALL_DIR" ]; then
        echo "Already in place: $INSTALL_DIR"
    else
        if [ -d "$INSTALL_DIR" ]; then
            echo "Error: $INSTALL_DIR already exists." >&2
            echo "Remove it first or set PIQUE_INSTALL_DIR." >&2
            exit 1
        fi
        mkdir -p "$(dirname "$INSTALL_DIR")"
        cp -r "$SOURCE_DIR" "$INSTALL_DIR"
        echo "Copied to: $INSTALL_DIR"
    fi
else
    if [ -d "$INSTALL_DIR/.git" ]; then
        echo "Updating: $INSTALL_DIR"
        cd "$INSTALL_DIR"
        git pull --ff-only
    else
        echo "Cloning to: $INSTALL_DIR"
        mkdir -p "$(dirname "$INSTALL_DIR")"
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
fi

# --- Trust mise config ---

cd "$INSTALL_DIR"
mise trust 2>/dev/null || true

# --- Install tools ---

echo ""
echo "Installing tools (node, pi)..."
mise install

# --- Create sessions directories ---

echo ""
echo "Creating session directories..."
for dir in "$INSTALL_DIR"/profiles/*/; do
    name=$(basename "$dir")
    mkdir -p "$INSTALL_DIR/sessions/$name"
done

# --- Install launcher ---

echo ""
echo "Installing launcher..."
chmod +x "$INSTALL_DIR/bin/pique"
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/bin/pique" "$BIN_DIR/$COMMAND_NAME"
echo "  $BIN_DIR/$COMMAND_NAME -> $INSTALL_DIR/bin/pique"

# --- Check PATH ---

if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    echo ""
    echo "Warning: $BIN_DIR is not in your PATH." >&2
    echo "Add this to your shell profile:" >&2
    echo "" >&2
    echo "  export PATH=\"$BIN_DIR:\$PATH\"" >&2
fi

# --- Done ---

echo ""
echo "=== Installation complete ==="
echo ""
echo "Repository:  $INSTALL_DIR"
echo "Command:     $BIN_DIR/$COMMAND_NAME"
echo "Profiles:    $INSTALL_DIR/profiles"
echo ""
echo "Test:"
echo "  pique --list"
echo "  pique minimal --version"
echo ""
echo "Available profiles:"
for dir in "$INSTALL_DIR"/profiles/*/; do
    name=$(basename "$dir")
    echo "  - $name"
done
