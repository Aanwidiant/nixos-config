{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    librewolf
    libreoffice
    mousepad
    evince
    thunar
    localsend
    imv
    mpv
    gnome-calculator
    cheese
    geary
    blanket
    ppsspp-sdl-wayland
    organicmaps
    figma-linux
  ];
}
