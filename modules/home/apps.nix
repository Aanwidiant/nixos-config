{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    librewolf
    libreoffice
    mousepad
    evince
    nautilus
    localsend
    imv
    mpv
    gnome-calculator
    cheese
    geary
  ];
}
