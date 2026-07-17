{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
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
  ];
}
