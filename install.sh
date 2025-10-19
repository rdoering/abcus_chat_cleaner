#!/bin/bash

set -e

# XDG_DATA_HOME setzen (Standard: ~/.local/share)
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_DIR="$XDG_DATA_HOME/abcus_chat_cleaner"
BIN_DIR="$HOME/.local/bin"
SYMLINK_PATH="$BIN_DIR/abcus_clean_chat"

echo "=== Abcus Chat Cleaner Installation ==="
echo ""

# Prüfe ob Git installiert ist
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git first."
    exit 1
fi

# Prüfe ob jq installiert ist
if ! command -v jq &> /dev/null; then
    echo "Warning: jq is not installed. The script requires jq to work."
    echo "Install it with: brew install jq (macOS) or apt-get install jq (Linux)"
    read -p "Continue anyway? (y/n): " continue_install
    if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Erstelle XDG_DATA_HOME Verzeichnis falls nicht vorhanden
if [ ! -d "$XDG_DATA_HOME" ]; then
    echo "Creating $XDG_DATA_HOME..."
    mkdir -p "$XDG_DATA_HOME"
fi

# Erstelle bin Verzeichnis falls nicht vorhanden
if [ ! -d "$BIN_DIR" ]; then
    echo "Creating $BIN_DIR..."
    mkdir -p "$BIN_DIR"
fi

# Prüfe ob das Repo bereits existiert
if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR already exists."
    read -p "Do you want to update the existing installation? (y/n): " update_install
    if [[ "$update_install" =~ ^[Yy]$ ]]; then
        echo "Updating existing installation..."
        cd "$INSTALL_DIR"
        git pull origin main || git pull origin master
    else
        echo "Installation cancelled."
        exit 0
    fi
else
    # Clone das Repository
    echo "Cloning repository to $INSTALL_DIR..."
    git clone git@github.com:rdoering/abcus_chat_cleaner.git "$INSTALL_DIR"
fi

# Mache das Skript ausführbar
chmod +x "$INSTALL_DIR/clean.sh"

# Erstelle oder aktualisiere Symlink
if [ -L "$SYMLINK_PATH" ] || [ -e "$SYMLINK_PATH" ]; then
    echo "Removing existing symlink/file at $SYMLINK_PATH..."
    rm -f "$SYMLINK_PATH"
fi

echo "Creating symlink: $SYMLINK_PATH -> $INSTALL_DIR/clean.sh"
ln -s "$INSTALL_DIR/clean.sh" "$SYMLINK_PATH"

# Prüfe ob $BIN_DIR im PATH ist
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo "Warning: $BIN_DIR is not in your PATH."
    echo "Add the following line to your ~/.zshrc or ~/.bashrc:"
    echo ""
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "The script has been installed to: $INSTALL_DIR"
echo "You can now run it with: abcus_clean_chat"
echo ""
echo "Examples:"
echo "  abcus_clean_chat --older-than 30 --dry-run"
echo "  abcus_clean_chat --older-than 7"
echo ""
echo "For more information, see: $INSTALL_DIR/README.md"
