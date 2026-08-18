{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    impala
    bluetui
    wiremix
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
