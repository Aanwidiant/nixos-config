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
link waybar .config/waybar
link mako .config/mako
link wofi .config/wofi
link swayosd .config/swayosd
link kitty .config/kitty
link theme .config/theme
link bash .config/bash
link hooks .config/hooks
link btop .config/btop
link fastfetch .config/fastfetch
link nvim .config/nvim
link starship/starship.toml .config/starship.toml
link scripts .local/bin

echo "Dotfiles linked ✔"
