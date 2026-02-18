{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hypridle
    hyprlock
    waybar
    mako
    wofi
    swayosd
    nwg-displays
    hyprpicker
    hyprsunset
    swaybg
  ];
}
