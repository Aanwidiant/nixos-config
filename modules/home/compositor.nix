{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swayidle
    hyprlock
    waybar
    mako
    swayosd
    hyprpicker
    wlsunset
    swaybg
    fuzzel
  ];
}
