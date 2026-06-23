{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    libreoffice
    # onlyoffice-desktopeditors
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
    artix-games-launcher
    ocrfeeder
    zotero
  ];
}
