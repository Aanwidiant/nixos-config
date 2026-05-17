{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swayidle
    hyprlock
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
