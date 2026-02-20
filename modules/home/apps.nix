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
    cheese
  ];
}
