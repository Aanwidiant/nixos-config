{ pkgs, ... }:

{
  home.packages = with pkgs; [
    foot
    htop
    powertop
    calcure
    ncdu
    yazi
    cava
    cliamp
  ];
}
