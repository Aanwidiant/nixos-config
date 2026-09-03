{ pkgs, ... }:

{
  home.packages = with pkgs; [
    foot
    impala
    bluetui
    wiremix
    htop
    powertop
    calcure
    ncdu
    yazi
    cava
    cliamp
  ];
}
