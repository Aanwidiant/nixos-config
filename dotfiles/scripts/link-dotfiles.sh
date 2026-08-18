#!/usr/bin/env bash
set -e

DOTFILES="$HOME/nixos-config/dotfiles"

link() {
    local src="$DOTFILES/$1"
    local dest="$HOME/$2"

    mkdir -p "$(dirname "$dest")"

    if [[ -e "$dest" && ! -L "$dest" ]]; then
        rm -rf "$dest"
    fi

    ln -sfn "$src" "$dest"
}

link hypr .config/hypr
link mango .config/mango
link quickshell .config/quickshell
link kitty .config/kitty
link theme .config/theme
link btop .config/btop
link zed .config/zed
link scripts .local/bin
link applications .local/share/applications
link nvim .config/nvim

echo "Dotfiles linked ✔"
