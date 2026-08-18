{ pkgs, ... }:

{
  home.packages = with pkgs; [
    libreoffice
    librewolf
    onlyoffice-desktopeditors
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
    organicmaps
    keepassxc
    obsidian
    brave-origin
  ];
}
