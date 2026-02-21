{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    bluetuith
    wifitui
    wiremix
    fastfetch
    btop
    htop
    powertop
    calcure
    clock-rs
    gum
    ncdu
    yazi
  ];
}
