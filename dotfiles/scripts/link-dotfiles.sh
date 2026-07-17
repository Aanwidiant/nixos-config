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

link mango          .config/mango
link swayidle      .config/swayidle
link swaylock      .config/swaylock
link waybar .config/waybar
link mako .config/mako
link fuzzel .config/fuzzel
link swayosd .config/swayosd
link kitty .config/kitty
link theme .config/theme
link bash .config/bash
link hooks .config/hooks
link btop .config/btop
link fastfetch .config/fastfetch
link zed .config/zed
link starship/starship.toml .config/starship.toml
link scripts .local/bin
link applications .local/share/applications

echo "Dotfiles linked ✔"
