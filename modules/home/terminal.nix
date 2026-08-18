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
    ncdu
    yazi
    cava
    cliamp
  ];
}
