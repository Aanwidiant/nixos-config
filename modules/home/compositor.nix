{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swayidle
    swaylock
    waybar
    mako
    wofi
    swayosd
    nwg-displays
    wl-color-picker
    wlsunset
    swaybg
  ];
}
