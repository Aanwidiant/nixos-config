{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    impala
    bluetui
    wiremix
    fastfetch
    btop
    htop
    powertop
    calcure
    clock-rs
    gum
  ];
}
