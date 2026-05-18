{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swayidle
    hyprlock
    waybar
    mako
    swayosd
    nwg-displays
    hyprpicker
    wlsunset
    swaybg
    fuzzel
  ];
}
