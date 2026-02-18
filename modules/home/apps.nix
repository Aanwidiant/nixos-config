{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    firefox
    libreoffice
    mousepad
    evince
    nautilus
    localsend
    imv
    mpv
    gnome-calculator
    gnome-disk-utility
    gnome-calendar
    baobab
    cheese
  ];
}
