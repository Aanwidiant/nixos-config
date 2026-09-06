{ pkgs, ... }:

{
  home.packages = with pkgs; [
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
