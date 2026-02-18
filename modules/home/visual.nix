{ pkgs, ... }:

{
  home.packages = with pkgs; [
    terminaltexteffects
    wofi-emoji
  ];
}
