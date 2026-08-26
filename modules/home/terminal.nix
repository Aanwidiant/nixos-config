{ pkgs, ... }:

{
  home.packages = with pkgs; [
    foot
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
