{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swayidle
    hyprlock
    waybar
    mako
    swayosd
    nwg-displays
    wl-color-picker
    wlsunset
    swaybg
    fuzzel
  ];
}
